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
//__-' { |          \        *** CroblancPrivateSale ***
//    /             \
//    /       "O.  |O }      Pre-sale on Whitelist
//    |            \ ;       The contract that collects USDC and releases CROBLANC linearly over time.
//                  ',
//       \_         __\
//         ''-_    \.//
//           / '-____'
//          /
//        _'
//      _-'
//----------------------------------------------------------------------------------------------------------------------
contract CroblancPrivateSale is Ownable {
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

    address constant public WHITELIST_SIGNER_ADDRESS = 0x6bD43b2F8c0fA1946436318cE9de000161b182Ba;
    uint256 constant public MAXIMUM_DISTRIBUTION = 10000000e18; // 10,000,000 max
    //                                                     166666.................. (18 decimals)
    uint256 constant public MAXIMUM_CROBLANC_PER_ADDRESS = 166666666666666666666667; // 166,666.6666... max per address
    uint256 constant public CROBLANC_PRICE_USDC = 15e4; // 0.15 USDC => 6 decimals, 1e6=$1.00, 1e5=$0.10, 1e4=$0.01
    uint256 constant public MINIMUM_BUY_USDC = 1500e6;  // 1,500 USDC
    uint256 constant public MAXIMUM_BUY_USDC = 25000e6; // 25,000 USDC

    event Participate(address indexed user, uint256 amountUsdc, uint256 amountCroblanc);

    mapping (address => bool) public whitelist;
    mapping (address => Allocation) public allocations;

    modifier onlyValidAccess(uint8 _v, bytes32 _r, bytes32 _s) {
        require(isValidAccessMessage(msg.sender,_v,_r,_s), "Invalid ECDSA signature");
        _;
    }

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

    function formMessage(address userAddress) external view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), userAddress));
    }

    function isValidAccessMessage(address _add, uint8 _v, bytes32 _r, bytes32 _s) view public returns (bool) {
        bytes memory packedHash = abi.encodePacked(address(this), _add);
        bytes32 hash = keccak256(packedHash);

        bytes memory packedString = abi.encodePacked("\x19Ethereum Signed Message:\n32", hash);
        return ecrecover(keccak256(packedString), _v, _r, _s) == WHITELIST_SIGNER_ADDRESS || ecrecover(keccak256(packedString), _v, _r, _s) == owner();
    }

    function getOutput(uint256 _input) public pure returns (uint256) {
        uint256 unit = 1e18;
        return unit.div(CROBLANC_PRICE_USDC).mul(_input);
    }

    function participate(uint256 _amountUsdc, uint8 _v, bytes32 _r, bytes32 _s) external onlyValidAccess(_v,_r,_s) {
        require(block.timestamp >= openAt, "Sale not yet started");
        require(block.timestamp <= closeAt, "Sale ended");
        require(_amountUsdc >= MINIMUM_BUY_USDC, "Under minimum amount");
        require(_amountUsdc <= MAXIMUM_BUY_USDC, "Over maximum amount");

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
