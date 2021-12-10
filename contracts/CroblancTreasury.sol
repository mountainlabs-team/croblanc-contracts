// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//----------------------------------------------------------------------------------------------------------------------
//        _
//       / \      _-'        *** CroblancTreasury ***
//     _/|  \-''- _ /
//__-' { |          \        Trustless revenue sharing between our four team members.
//    /             \
//    /       "O.  |O }      Public users are not involved and should not interact with this contract.
//    |            \ ;
//                  ',       Feel free to reuse for your own projects.
//       \_         __\
//         ''-_    \.//
//           / '-____'
//          /
//        _'
//      _-'
//----------------------------------------------------------------------------------------------------------------------
contract CroblancTreasury is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 emergencyUnlockTime = 0;
    uint256 emergencyUnlockDelay;

    struct TokenShare {
        uint256 lastBalance;
        uint256 b; // Claimable balance for B
        uint256 c; // Claimable balance for C
        uint256 d; // Claimable balance for D
        uint256 m; // Claimable balance for M
    }

    mapping(address => TokenShare) public tokenShares;

    address public b;
    address public c;
    address public d;
    address public m;

    event EmergencyUnlockRequested(uint256 unlockTime);

    constructor (
        address _b,
        address _c,
        address _d,
        address _m,
        uint256 _emergencyUnlockDelay
    ) public {
        b = _b;
        c = _c;
        d = _d;
        m = _m;
        emergencyUnlockDelay = _emergencyUnlockDelay;
    }

    modifier onlyTeamMember {
        require(msg.sender == b || msg.sender == c || msg.sender == d || msg.sender == m);
        _;
    }

    function claimTokens(address _token) external onlyTeamMember {
        TokenShare storage tokenShare = tokenShares[_token];
        IERC20 token = IERC20(_token);
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 notUpdatedBalance = currentBalance.sub(tokenShare.lastBalance);

        // Update users balances
        if (notUpdatedBalance > 0) {
            // One 22.5% share value
            uint256 oneShare = notUpdatedBalance.mul(225).div(1000); // mul() before div(), to avoid int rounding issues

            // Gives a share to C
            tokenShare.c = tokenShare.c.add(oneShare);
            notUpdatedBalance = notUpdatedBalance.sub(oneShare);

            // Gives a share to D
            tokenShare.d = tokenShare.d.add(oneShare);
            notUpdatedBalance = notUpdatedBalance.sub(oneShare);

            // Gives a share to M
            tokenShare.m = tokenShare.m.add(oneShare);
            notUpdatedBalance = notUpdatedBalance.sub(oneShare);

            // Gives the remaining to B (32.5% +/- calculation rounding dust)
            tokenShare.b = tokenShare.b.add(notUpdatedBalance);
        }

        // Determine the amount based on who is calling the method
        uint256 transferAmount = 0;
        if (msg.sender == c) {
            transferAmount = tokenShare.c;
            tokenShare.c = 0;
        }
        if (msg.sender == d) {
            transferAmount = tokenShare.d;
            tokenShare.d = 0;
        }
        if (msg.sender == m) {
            transferAmount = tokenShare.m;
            tokenShare.m = 0;
        }
        if (msg.sender == b) {
            transferAmount = tokenShare.b;
            tokenShare.b = 0;
        }

        // No empty transfer
        require(transferAmount > 0);

        // Prevent decimal rounding errors
        if (transferAmount > currentBalance) {
            transferAmount = currentBalance;
        }

        // Send the tokens
        token.transfer(msg.sender, transferAmount);
        tokenShare.lastBalance = currentBalance.sub(transferAmount);
    }

    // UI helper view
    function claimableTokens(address _user, address _token) public view returns (uint256) {
        TokenShare storage tokenShare = tokenShares[_token];
        IERC20 token = IERC20(_token);
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 notUpdatedBalance = currentBalance.sub(tokenShare.lastBalance);

        if (_user == c) {
            return tokenShare.c.add(notUpdatedBalance.mul(225).div(1000));
        }
        if (_user == d) {
            return tokenShare.d.add(notUpdatedBalance.mul(225).div(1000));
        }
        if (_user == m) {
            return tokenShare.m.add(notUpdatedBalance.mul(225).div(1000));
        }
        if (_user == b) {
            return tokenShare.b.add(notUpdatedBalance.mul(325).div(1000));
        }
        return 0;
    }

    // In case one of the team member lost his wallet, Owner can unlock ALL funds after a safety delay of 1 month
    // Emit a EmergencyUnlock event to let all the team know we are going to unlock ALL FUNDS in 1 month
    // EMERGENCY ONLY, a new Treasury must be set later!
    function emergencyUnlock() external onlyOwner {
        emergencyUnlockTime = block.timestamp.add(emergencyUnlockDelay);
        emit EmergencyUnlockRequested(emergencyUnlockTime);
    }

    function emergencyWithdraw(address _token) public onlyOwner {
        require(emergencyUnlockTime > 0);
        require(block.timestamp > emergencyUnlockTime);
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }
}
