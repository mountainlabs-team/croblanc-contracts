// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//----------------------------------------------------------------------------------------------------------------------
//        _
//       / \      _-'        *** CroblancTimelock ***
//     _/|  \-''- _ /
//__-' { |          \        Simple timelock contract to secure the initial liquidity.
//    /             \
//    /       "O.  |O }
//    |            \ ;
//                  ',
//       \_         __\
//         ''-_    \.//
//           / '-____'
//          /
//        _'
//      _-'
//----------------------------------------------------------------------------------------------------------------------
contract CroblancTimelock is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct TokenLock {
        uint256 unlockAt;
    }

    uint256 constant public LOCK_DURATION = 31536000; // 1 year

    mapping (address => TokenLock) public tokenLocks;

    event Locked(address indexed token, uint256 amount, uint256 unlockAt);

    constructor () public {
    }

    function pullAndLock(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        tokenLocks[_token].unlockAt = block.timestamp + LOCK_DURATION;

        emit Locked(_token, _amount, block.timestamp + LOCK_DURATION);
    }

    function withdraw(address _token) external onlyOwner {
        require(tokenLocks[_token].unlockAt > 0);
        require(block.timestamp > tokenLocks[_token].unlockAt);

        IERC20(_token).safeTransfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }
}
