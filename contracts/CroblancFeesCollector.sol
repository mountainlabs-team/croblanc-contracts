// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/uniswap/IUniswapV2Router02.sol";
import "./interfaces/IWETH.sol";
import "./CroblancToken.sol";
import "./CroblancDividends.sol";

//----------------------------------------------------------------------------------------------------------------------
//        _
//       / \      _-'
//     _/|  \-''- _ /
//__-' { |          \        *** CroblancFeesCollector ***
//    /             \
//    /       "O.  |O }      Pull rewards from the reward address, swap them into WCRO, execute the CROBLANC buyback on
//    |            \ ;       the market, and send the WCRO to the dividends pools, and reward the user with a bounty.
//                  ',       When using CroblancFeesCollector, the buyback feature from the dividends pool must be
//       \_         __\      disabled.
//         ''-_    \.//
//           / '-____'
//          /
//        _'
//      _-'
//----------------------------------------------------------------------------------------------------------------------
contract CroblancFeesCollector is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct ThirdPartyPlatform {
        IERC20 want;
        IUniswapV2Router02 router;
        address[] route;
    }

    uint256 lastSwapTimestamp;
    uint256 bountyPerDay = 48e18; // 48 CROBLANC per day or 2 CROBLANC per hour

    ThirdPartyPlatform[] public thirdPartyPlatforms;

    // Tokens
    address constant public wcroAddress = address(0x5C7F8A570d578ED84E63fdFA7b1eE72dEae1AE23);
    IERC20 public wcro;
    CroblancToken public croblanc;
    CroblancDividends public dividends;
    address public feesRecipient;
    address public treasury;
    address public reserve;
    IUniswapV2Router02 public buybackRouter;
    bool public buybackEnabled;

    constructor (
        address _croblanc,
        address _dividends,
        address _feesRecipient,
        address _reserve,
        address _treasury
    ) public {
        croblanc = CroblancToken(_croblanc);
        dividends = CroblancDividends(_dividends);
        feesRecipient = _feesRecipient;
        reserve = _reserve;
        treasury = _treasury;
        wcro = IERC20(wcroAddress);

        // CronaSwap
        address[] memory r1 = new address[](2);
        r1[0] = 0xadbd1231fb360047525BEdF962581F3eee7b49fe;
        r1[1] = wcroAddress;
        thirdPartyPlatforms.push(ThirdPartyPlatform(
            IERC20(0xadbd1231fb360047525BEdF962581F3eee7b49fe), // _want (CRONA)
            IUniswapV2Router02(0xcd7d16fB918511BF7269eC4f48d61D79Fb26f918), // _router (CronaSwapRouter)
            r1 // _route
        ));

        // VVSFinance
        address[] memory r2 = new address[](2);
        r2[0] = 0x2D03bECE6747ADC00E1a131BBA1469C15fD11e03;
        r2[1] = wcroAddress;
        thirdPartyPlatforms.push(ThirdPartyPlatform(
            IERC20(0x2D03bECE6747ADC00E1a131BBA1469C15fD11e03), // _want (VVS)
            IUniswapV2Router02(0x145863Eb42Cf62847A6Ca784e6416C1682b1b2Ae), // _router (VVSRouter)
            r2 // _route
        ));

        // CrowFi
        address[] memory r3 = new address[](2);
        r3[0] = 0x285c3329930a3fd3C7c14bC041d3E50e165b1517;
        r3[1] = wcroAddress;
        thirdPartyPlatforms.push(ThirdPartyPlatform(
            IERC20(0x285c3329930a3fd3C7c14bC041d3E50e165b1517), // _want (CROW)
            IUniswapV2Router02(0xd30d3aC04E2325E19A2227cfE6Bc860376Ba20b1), // _router (CrowRouter)
            r3 // _route
        ));

        buybackEnabled = true;
        buybackRouter = IUniswapV2Router02(0xcd7d16fB918511BF7269eC4f48d61D79Fb26f918);

        _giveAllowances();
    }

    function thirdPartyPlatformsLength() external view returns (uint256) {
        return thirdPartyPlatforms.length;
    }

    function getThirdPartyPlatforms() external view returns (ThirdPartyPlatform[] memory) {
        return thirdPartyPlatforms;
    }

    function addThirdPartyPlatform(address _want, address _router, address[] memory _route, bool giveAllowances) public onlyOwner {
        thirdPartyPlatforms.push(ThirdPartyPlatform(IERC20(_want), IUniswapV2Router02(_router), _route));
        if (giveAllowances) {
            _giveAllowances();
        }
    }

    function removeThirdPartyPlatform(uint256 _index) public onlyOwner {
        // Disable allowance
        thirdPartyPlatforms[_index].want.approve(address(thirdPartyPlatforms[_index].router), 0);
        // Swap
        thirdPartyPlatforms[_index] = thirdPartyPlatforms[thirdPartyPlatforms.length - 1];
        // and Pop
        thirdPartyPlatforms.pop();
    }

    function _hasSomethingToSwap() internal view returns (bool) {
        for (uint256 i = 0; i < thirdPartyPlatforms.length ; i++) {
            if (thirdPartyPlatforms[i].want.balanceOf(feesRecipient) > 1e18) {
                return true;
            }
        }
        return false;
    }

    function bountyAmount() public view returns (uint256) {
        // No bounty if nothing to swap
        if (block.timestamp <= lastSwapTimestamp || !_hasSomethingToSwap()) {
            return 0;
        }

        return block.timestamp.sub(lastSwapTimestamp).mul(bountyPerDay).div(86400);
    }

    function distributeDividends() external whenNotPaused nonReentrant {
        // Calculate the bounty
        uint256 bounty = bountyAmount();

        // Pull funds from the fees recipient address
        for (uint256 i = 0; i < thirdPartyPlatforms.length ; i++) {
            thirdPartyPlatforms[i].want.transferFrom(feesRecipient, address(this), thirdPartyPlatforms[i].want.balanceOf(feesRecipient));
        }

        // Swap everything to wcro
        address[] memory r;
        for (uint256 i = 0; i < thirdPartyPlatforms.length ; i++) {
            // Execute swap if balance is at least 1
            if (thirdPartyPlatforms[i].want.balanceOf(address(this)) > 1e18) {
                // Conversion of route to dynamic size memory array
                r = new address[](thirdPartyPlatforms[i].route.length);
                for (uint256 j = 0; j < thirdPartyPlatforms[i].route.length ; j++) {
                    r[j] = thirdPartyPlatforms[i].route[j];
                }

                thirdPartyPlatforms[i].router.swapExactTokensForTokens(
                    thirdPartyPlatforms[i].want.balanceOf(address(this)),
                    1,
                    r,
                    address(this),
                    type(uint256).max
                );
            }
        }

        uint256 wcroBalance = wcro.balanceOf(address(this));
        if (wcroBalance > 1e18) {
            uint256 oneQuarter = wcroBalance.div(4);

            // Send 1/4 to treasury
            wcro.transfer(treasury, oneQuarter);

            // Send 1/4 to reserve
            wcro.transfer(reserve, oneQuarter);

            if (buybackEnabled) {
                // Buyback 1/4
                address[] memory buybackRoute = new address[](2);
                buybackRoute[0] = wcroAddress;
                buybackRoute[1] = address(croblanc);

                buybackRouter.swapExactTokensForTokens(
                    oneQuarter,
                    1,
                    buybackRoute,
                    reserve,
                    type(uint256).max
                );
            }

            // Send remaining to dividends. Do not use dividends buyback anymore.
            dividends.pullDividends(address(this), wcro.balanceOf(address(this)));
        }

        // No bounty the first time (or the calculation will be wrong)
        if (lastSwapTimestamp > 0) {
            // Give bounty to the caller
            croblanc.mint(msg.sender, bounty);
        }

        // Remember the swap time
        lastSwapTimestamp = block.timestamp;
    }

    function setBountyPerDay(uint256 _amount) external onlyOwner {
        require(_amount < 2400e18);
        bountyPerDay = _amount;
    }

    function disableBuyback() external onlyOwner {
        buybackEnabled = false;
        wcro.approve(address(buybackRouter), 0);
    }

    function setBuybackRouter(address _buybackRouter) external onlyOwner {
        buybackRouter = IUniswapV2Router02(_buybackRouter);
        wcro.approve(address(buybackRouter), type(uint256).max);
    }

    function enableBuyback() external onlyOwner {
        buybackEnabled = true;
        wcro.approve(address(buybackRouter), type(uint256).max);
    }

    function _giveAllowances() internal {
        // Allow dividends to pull wcro
        wcro.approve(address(dividends), type(uint256).max);
        wcro.approve(address(buybackRouter), type(uint256).max);

        // Allow each platform to pull its native token
        for (uint256 i = 0; i < thirdPartyPlatforms.length ; i++) {
            thirdPartyPlatforms[i].want.approve(address(thirdPartyPlatforms[i].router), type(uint256).max);
        }
    }

    function _revokeAllowances() internal {
        // Disallow dividends to pull wcro
        wcro.approve(address(dividends), 0);
        wcro.approve(address(buybackRouter), 0);

        // Disallow each platform to pull its native token
        for (uint256 i = 0; i < thirdPartyPlatforms.length ; i++) {
            thirdPartyPlatforms[i].want.approve(address(thirdPartyPlatforms[i].router), 0);
        }
    }

    function tokenRecovery(address _token) external onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender, amount);
    }
}
