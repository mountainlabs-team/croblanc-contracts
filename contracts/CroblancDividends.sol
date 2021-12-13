// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/cronaswap/IMasterChef.sol";
import "./interfaces/uniswap/IUniswapV2Router02.sol";
import "./interfaces/IWETH.sol";
import "./CroblancToken.sol";
import "./CroblancAlpha.sol";

//----------------------------------------------------------------------------------------------------------------------
//        _
//       / \      _-'
//     _/|  \-''- _ /
//__-' { |          \        *** CroblancDividends ***
//    /             \
//    /       "O.  |O }      Revenue sharing manager for Croblanc stakers.
//    |            \ ;       This contract is a single staking pool that also acts as the LP token.
//                  ',       It also pulls CRO directly from other addresses (all farms) and calculates the proper
//       \_         __\      revenue sharing between all token holders.
//         ''-_    \.//
//           / '-____'       There is also an optional auto-buyback of CROBLANC upon harvest
//          /
//        _'
//      _-'
//----------------------------------------------------------------------------------------------------------------------
contract CroblancDividends is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct AddressProposal {
        address newAddress;
        uint256 unlockTimestamp;
    }

    // Info of each user
    mapping(address => uint256) public wcroRewardDebt;
    mapping(address => uint256) public wcroAlreadyClaimedPerShare;

    // Tokens
    address constant public wcro = address(0x5C7F8A570d578ED84E63fdFA7b1eE72dEae1AE23);
    address public croblanc;
    address public treasury;
    address public routeFrom; // @todo Use an array of addresses
    address public routeTo;

    // Calculation of rewards
    uint256 public lastRewardTime;      // Timestamp of the last CROBLANCs distribution.
    uint256 public accWcroPerShare;     // Accumulated WCROs per share, times 1e18.
    uint256 public accWcroWithdrawn;
    uint256 public totalWcroPerShare;
    uint256 public totalWcroLifetime;

    // For CROBLANC buyback
    address public router = 0x145863Eb42Cf62847A6Ca784e6416C1682b1b2Ae; // VVS router
    AddressProposal public newRouter; // Update of router procedure
    bool public isBuybackEnabled = false; // Buyback can be set on/off

    // Events
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event NewRouterProposed(address indexed newAddress, uint256 unlockTime);
    event NewRouterDeployed(address indexed newAddress);

    constructor (
        address _croblanc,
        address _treasury,
        address _routeFrom,
        address _routeTo
    ) public ERC20("Dividend-Bearing Croblanc Token", "xCROBLANC") {
        croblanc = _croblanc;
        treasury = _treasury;
        routeFrom = _routeFrom;
        routeTo = _routeTo;
    }

    function pullDividends(address _address, uint256 _amount) external {
        // @todo This function code will be disclosed after the external auditing process is done
    }

    // View function to see pending WCRO on frontend.
    function pendingWcro(address _user) public view returns (uint256) {
        // @todo This function code will be disclosed after the external auditing process is done
    }

    // Public endpoint to harvest rewards for msg.sender
    function harvest() public {
        // Harvest for myself
        _harvestOnBehalfOf(msg.sender);
    }

    // Admin endpoint to force a harvest on behalf of another user
    function harvestOnBehalfOf(address _user) external onlyOwner {
        _harvestOnBehalfOf(_user);
    }

    // Harvest for a user
    function _harvestOnBehalfOf(address _user) internal {
        // @todo This function code will be disclosed after the external auditing process is done
    }

    function deposit(uint256 _amount) public nonReentrant {
        // @todo This function code will be disclosed after the external auditing process is done
    }

    function depositAll() public {
        deposit(IERC20(croblanc).balanceOf(msg.sender));
    }

    function withdraw(uint256 _amount) public nonReentrant {
        // @todo This function code will be disclosed after the external auditing process is done
    }

    function withdrawAll() public {
        withdraw(balanceOf(msg.sender));
    }

    function _buyback(uint256 _amountWcro) internal {
        // @todo This function code will be disclosed after the external auditing process is done
    }

    // @notice amount raises "Unused function parameter" warning. As it overrides native ERC20 code, we keep it anyway.
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        // @todo This function code will be disclosed after the external auditing process is done
    }

    // Warning! Enable buyback will immediately divide the pending wcro for everybody by 2
    function enableBuyback() external onlyOwner {
        isBuybackEnabled = true;
        _giveAllowances();
    }

    // Warning! Enable buyback will immediately multiply the pending wcro for everybody by 2
    function disableBuyback() external onlyOwner {
        isBuybackEnabled = false;
        _revokeAllowances();
    }

    function amendRoute(address _routeFrom, address _routeTo) external onlyOwner {
        routeFrom = _routeFrom;
        routeTo = _routeTo;
    }

    function _giveAllowances() internal {
        IERC20(wcro).approve(router, type(uint256).max);
    }

    function _revokeAllowances() internal {
        IERC20(wcro).approve(router, 0);
    }

    // Amend the router is delayed by 7 days to avoid any abuse of authority
    function proposeNewRouter(address _newAddress) external onlyOwner {
        // Access control
        require(newRouter.unlockTimestamp == 0);
        require(_newAddress != address(0));

        // Save proposal
        newRouter.unlockTimestamp = block.timestamp + 604800;
        newRouter.newAddress = _newAddress;

        // Alert everybody
        emit NewRouterProposed(_newAddress, newRouter.unlockTimestamp);
    }

    function deployNewRouter() external onlyOwner {
        // Access control
        require(newRouter.unlockTimestamp > 0);
        require(newRouter.unlockTimestamp <= block.timestamp);

        // Cancel previous allowances especially the one to the router
        _revokeAllowances();

        // Update router
        router = newRouter.newAddress;

        // Reset proposal
        newRouter.newAddress = address(0);
        newRouter.unlockTimestamp = 0;

        // Set a new allowance to the new router
        _giveAllowances();

        // Alert everybody
        emit NewRouterDeployed(newRouter.newAddress);
    }
}
