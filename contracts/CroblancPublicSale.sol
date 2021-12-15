// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./CroblancToken.sol";

//----------------------------------------------------------------------------------------------------------------------
//        _
//       / \      _-'
//     _/|  \-''- _ /
//__-' { |          \        *** CroblancPublicSale ***
//    /             \
//    /       "O.  |O }      Public Pre-sale
//    |            \ ;       The contract that collects USDC and releases CROBLANC linearly over time.
//                  ',
//       \_         __\
//         ''-_    \.//
//           / '-____'
//          /
//        _'
//      _-'
//----------------------------------------------------------------------------------------------------------------------
contract CroblancPublicSale is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct Allocation {
        uint256 total;
        uint256 alreadyClaimed;
    }

    CroblancToken public croblanc;
    IERC20 public usdc; // USD Coin contract address
    address public treasury;
    uint256 public openAt;
    uint256 public closeAt;
    uint256 public vestingStartAt;
    uint256 public vestingDuration;
    uint256 public totalAllocated;

    uint256 constant public MAXIMUM_DISTRIBUTION = 20000000e18; // 20,000,000 max = 2e(18+7) = 2e25
    uint256 constant public MAXIMUM_CROBLANC_PER_ADDRESS = 25000e18; // 25,000 max per address
    uint256 constant public CROBLANC_PRICE_USDC = 2e5;  // 0.20 USDC => 6 decimals
    uint256 constant public MINIMUM_BUY_USDC = 500e6;  // 500 USDC
    uint256 constant public MAXIMUM_BUY_USDC = 5000e6; // 5,000 USDC

    mapping (address => Allocation) public allocations;

    event Participate(address indexed user, uint256 amountUsdc, uint256 amountCroblanc);

    constructor (
        address _croblanc,
        address _usdc,
        uint256 _openAt,
        uint256 _closeAt,
        uint256 _vestingStartAt,
        uint256 _vestingDuration,
        address _treasury
    ) public {
        croblanc = CroblancToken(_croblanc);
        usdc = IERC20(_usdc);
        openAt = _openAt;
        closeAt = _closeAt;
        vestingStartAt = _vestingStartAt;
        vestingDuration = _vestingDuration;
        treasury = _treasury;
    }

    function getOutput(uint256 _input) public pure returns (uint256) {
        uint256 unit = 1e18;
        return unit.div(CROBLANC_PRICE_USDC).mul(_input);
    }

    function participate(uint256 _amountUsdc) external {
        require(block.timestamp >= openAt, "Sale not yet started"); // sale not yet started
        require(block.timestamp <= closeAt, "Sale ended"); // sale ended
        require(_amountUsdc >= MINIMUM_BUY_USDC, "Under minimum amount"); // under minimum
        require(_amountUsdc <= MAXIMUM_BUY_USDC, "Over maximum amount"); // over maximum

        uint256 amountCroblanc = getOutput(_amountUsdc);
        uint256 amountUsdc = _amountUsdc;
        Allocation storage allocation = allocations[msg.sender];

        // Check if sold out
        if (totalAllocated.add(amountCroblanc) > MAXIMUM_DISTRIBUTION) {
            // Adjust the amount
            amountCroblanc = MAXIMUM_DISTRIBUTION.sub(totalAllocated);
            amountUsdc = amountCroblanc.mul(CROBLANC_PRICE_USDC).div(1e18);
        }

        // Check if user exceeds his limit
        if (allocation.total.add(amountCroblanc) > MAXIMUM_CROBLANC_PER_ADDRESS) {
            // Adjust the amount
            amountCroblanc = MAXIMUM_CROBLANC_PER_ADDRESS.sub(allocation.total);
            amountUsdc = amountCroblanc.mul(CROBLANC_PRICE_USDC).div(1e18);
        }

        // Pull the USDC
        usdc.transferFrom(msg.sender, address(this), amountUsdc);

        // Save the allocation amount
        allocation.total = allocation.total.add(amountCroblanc);

        // Global allocation
        totalAllocated = totalAllocated.add(amountCroblanc);

        emit Participate(msg.sender, _amountUsdc, amountCroblanc);
    }

    // UI helper
    function remaining(address _user) external view returns (uint256) {
        Allocation storage allocation = allocations[_user];
        return allocation.total - allocation.alreadyClaimed;
    }

    // UI helper + calculation in actual claim action
    function claimable(address _user) public view returns (uint256) {
        Allocation storage allocation = allocations[_user];

        // Didn't receive any allocation
        if (allocation.total == 0) {
            return 0;
        }

        // Vesting not yet started
        if (block.timestamp < vestingStartAt) {
            return 0;
        }

        // Vesting already finished?
        uint256 totalClaimable = 0;
        if (block.timestamp >= vestingStartAt.add(vestingDuration)) {
            // Cap the totalClaimable
            totalClaimable = allocation.total;
        } else {
            // Prorata of unlocked CROBLANC
            uint256 vestingProgress = (block.timestamp - vestingStartAt).mul(1e12).div(vestingDuration);
            totalClaimable = allocation.total.mul(vestingProgress).div(1e12);
        }

        // The difference between the total claimable and how much already claimed
        return totalClaimable.sub(allocation.alreadyClaimed);
    }

    // Claim CROBLANC
    function _claim(address _user) internal returns (uint256) {
        require(block.timestamp >= vestingStartAt); // vesting not yet started

        Allocation storage allocation = allocations[_user];
        // Didn't receive any allocation
        if (allocation.total == 0) {
            // Returns immediately
            return 0;
        }

        // Calculate how much CROBLANC claimable
        uint256 toClaim = claimable(_user);
        if (toClaim > 0) {
            allocation.alreadyClaimed = allocation.alreadyClaimed.add(toClaim);
            croblanc.mint(_user, toClaim);
        }
        return toClaim;
    }

    // Claim for myself
    function claim() external returns (uint256) {
        return _claim(msg.sender);
    }

    // Just in case, an admin can claim the tokens on behalf of a user
    function claimOnBehalfOf(address _user) external onlyOwner returns (uint256) {
        return _claim(_user);
    }

    function withdrawToTreasury() external onlyOwner {
        usdc.transfer(treasury, usdc.balanceOf(address(this)));
    }
}
