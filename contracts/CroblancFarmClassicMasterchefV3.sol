// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/sushiswap/IGenericMasterChef.sol";
import "./CroblancAlpha.sol";
import "./CroblancToken.sol";

//----------------------------------------------------------------------------------------------------------------------
//        _
//       / \      _-'
//     _/|  \-''- _ /
//__-' { |          \        *** CroblancFarmClassicMasterchefV3 ***
//    /             \
//    /       "O.  |O }      In V3, the performance fee is not auto-swapped anymore.
//    |            \ ;       We send the funds into a fees receiver address, that will swap to WCRO and be sent
//                  ',       to the dividends pool later.
//       \_         __\
//         ''-_    \.//
//           / '-____'
//          /
//        _'
//      _-'                  /!\ NO SUPPORT OF DEFLATIONARY TOKENS IN THIS VERSION /!\
//----------------------------------------------------------------------------------------------------------------------
abstract contract CroblancFarmClassicMasterchefV3 is ERC20, Ownable, Pausable, ReentrancyGuard {
    using SafeMath for uint256;

    // Info of each user.
    struct UserInfo {
        uint256 wheatRewardDebt;    // Inspired by MasterChef virtual reward debt calculation method
        uint256 croblancRewardDebt; // Inspired by MasterChef virtual reward debt calculation method
    }

    // Info of each
    mapping(address => UserInfo) public userInfo;

    // Uints256
    uint256 public lastRewardTime;      // Timestamp of the last CROBLANCs distribution.
    uint256 public accCroblancPerShare; // Accumulated CROBLANCs per share, times 1e18.
    uint256 public accWheatPerShare;    // Accumulated CRONAs per share, times 1e18.
    uint256 public masterChefPoolId;    // CronaSwap pool id
    uint256 public stakedWant;          // Amount of want already staked on MasterChef
    bool public masterChefEnabled;      // Should we deposit the LP into masterchef?

    // Addresses and third-parties
    IERC20 public want;                   // Address of LP token contract we want to accumulate in this farm.
    IERC20 public wheat;                  // Token farmed by the underlying farm, in this case CRONA
    IERC20 public wcro;                   // WCRO
    CroblancAlpha public alpha;           // Master emission control
    CroblancToken public croblanc;        // CROBLANC
    IGenericMasterChef public masterChef; // MasterChef contract
    address public constant wcroAddress = address(0x5C7F8A570d578ED84E63fdFA7b1eE72dEae1AE23);
    address public feeRecipient;          // Address that receives the fees

    // Events
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor (
        string memory _name,
        string memory _symbol,
        address _alpha,
        address _croblanc,
        address _feeRecipient,
        address _want,
        address _wheat,
        address _masterChef,
        uint256 _masterChefPoolId
    ) public ERC20(_name, _symbol) {
        alpha = CroblancAlpha(_alpha);
        croblanc = CroblancToken(_croblanc);
        feeRecipient = _feeRecipient;
        want = IERC20(_want);
        wheat = IERC20(_wheat);
        wcro = IERC20(wcroAddress);
        masterChef = IGenericMasterChef(_masterChef);
        masterChefPoolId = _masterChefPoolId;

        // Allow masterchef to pull our third-party LPs
        _giveAllowances();

        // We can list LP tokens that have no rewards on masterchef, that's ok
        masterChefEnabled = (_masterChefPoolId > 0);
    }

    // View function to see pending CROBLANCs on frontend.
    function pendingCroblanc(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 userBalance = balanceOf(_user);
        uint256 wantBalance = want.balanceOf(address(this)).add(stakedWant);

        if (wantBalance == 0 || userBalance == 0) {
            return 0;
        }

        uint256 accCroblancPerShareView = accCroblancPerShare;
        if (block.timestamp > lastRewardTime && wantBalance != 0) {
            uint256 reward = alpha.getReward(address(this), lastRewardTime, block.timestamp);
            accCroblancPerShareView = accCroblancPerShareView.add(reward.mul(1e18).div(wantBalance));
        }
        return userBalance.mul(accCroblancPerShareView).div(1e18).sub(user.croblancRewardDebt);
    }

    function pendingRewardInMasterChef() virtual public view returns (uint256) {
        // Must adapt this for every platform, they like to rename the base Sushiswap functions
        return masterChef.pendingSushi(masterChefPoolId, address(this));
    }

    // View function to see pending CRONAs on frontend
    function pendingWheat(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 userBalance = balanceOf(_user);
        uint256 wantBalance = want.balanceOf(address(this)).add(stakedWant);

        if (wantBalance == 0 || userBalance == 0) {
            return 0;
        }

        // Already harvested and pending for this user, performance fee has already been charged
        uint256 wheatAlreadyHarvested = userBalance.mul(accWheatPerShare).div(1e18).sub(user.wheatRewardDebt);

        uint256 wheatHarvestable = 0;
        if (masterChefEnabled) {
            // Harvestable wheat in the third-party, net of performance fee
            wheatHarvestable = pendingRewardInMasterChef().mul(userBalance).div(wantBalance).mul(1000 - alpha.performanceFeePerThousand()).div(1000);
        }

        return wheatAlreadyHarvested.add(wheatHarvestable);
    }

    // Public endpoint to harvest rewards for msg.sender
    function harvest() public whenNotPaused {
        // Harvest for myself
        _harvestOnBehalfOf(msg.sender);
    }

    // Admin endpoint to force a harvest on behalf of another user
    function harvestOnBehalfOf(address _user) external onlyOwner {
        _harvestOnBehalfOf(_user);
    }

    // Harvest for a user
    function _harvestOnBehalfOf(address _user) internal {
        // Harvest underlying farms
        updatePool(true);

        UserInfo storage user = userInfo[_user];
        uint256 userBalance = balanceOf(_user);

        // Get pending Croblanc for this user
        uint256 croblancAmount = pendingCroblanc(_user);

        // Get pending Wheat for this user
        // At this point, wheatAmount is directly equal to the users shares minus the reward debt. We do not need to
        // count what is pending in Masterchef because the pool has already been updated earlier in
        // this function. Consequently, to save some gas we can replace pendingWheat(_user) by the direct calculation.
        //uint256 wheatAmount = pendingWheat(_user);
        uint256 wheatAmount = userBalance.mul(accWheatPerShare).div(1e18).sub(user.wheatRewardDebt);

        if (croblancAmount > 0) {
            // Safety check
            if (croblanc.balanceOf(address(this)) < croblancAmount) {
                croblancAmount = croblanc.balanceOf(address(this));
            }
            // Transfer the croblanc to the user
            croblanc.transfer(_user, croblancAmount);
        }
        if (wheatAmount > 0) {
            // Safety check!
            if (wheat.balanceOf(address(this)) < wheatAmount) {
                wheatAmount = wheat.balanceOf(address(this));
            }
            // Transfer the croblanc to the user
            wheat.transfer(_user, wheatAmount);
        }
        // Reset user debt
        user.croblancRewardDebt = userBalance.mul(accCroblancPerShare).div(1e18);
        user.wheatRewardDebt = userBalance.mul(accWheatPerShare).div(1e18);
    }
    
    // Update reward variables of the given pool to be up-to-date.
    function updatePool(bool _harvestMasterchef) public whenNotPaused {
        if (block.timestamp <= lastRewardTime) {
            return;
        }
        uint256 wantBalance = want.balanceOf(address(this)).add(stakedWant);
        if (wantBalance == 0) {
            lastRewardTime = block.timestamp;
            return;
        }

        // Liquidity mining for CROBLANC
        uint256 croblancReward = alpha.getReward(address(this), lastRewardTime, block.timestamp);

        uint256 actuallyMinted = croblanc.safeMint(address(this), croblancReward);
        accCroblancPerShare = accCroblancPerShare.add(actuallyMinted.mul(1e18).div(wantBalance));

        // Harvesting Rewards (CRONA / VVS / CROW / whatever)
        // Never harvest wheat on alpha.massUpdatePools to save a LOT of gas
        if (_harvestMasterchef && masterChefEnabled) {
            // How many Rewards the farm already has
            uint256 wheatBalanceBeforeHarvest = wheat.balanceOf(address(this));

            // Making a zero deposit in masterChef means harvest the pending Rewards
            _depositToThirdParty(0);

            // Newly harvested Rewards
            uint256 wheatHarvested = wheat.balanceOf(address(this)).sub(wheatBalanceBeforeHarvest);

            // Calculate the performance fee and send to the recipient address
            uint256 performanceFee = wheatHarvested.mul(alpha.performanceFeePerThousand()).div(1000);
            if (performanceFee > 0) {
                wheat.transfer(feeRecipient, performanceFee);
            }

            // Count rewards for wheat distribution
            uint256 wheatRedistributed = wheatHarvested.sub(performanceFee);
            if (wheatRedistributed > 0) {
                accWheatPerShare = accWheatPerShare.add(wheatRedistributed.mul(1e18).div(wantBalance));
            }
        }

        lastRewardTime = block.timestamp;
    }

    function deposit(uint256 _amount) public nonReentrant whenNotPaused {
        require(_amount > 0);

        // Reference to this userInfo entry
        UserInfo storage user = userInfo[msg.sender];
        uint256 userBalance = balanceOf(msg.sender);

        // User already has LP tokens deposited
        if (userBalance > 0) {
            // Force a harvest first
            harvest();
        } else {
            // Harvest external rewards without user harvest
            updatePool(true);
        }

        // Pull his LP tokens
        want.transferFrom(msg.sender, address(this), _amount);

        // Put funds to work
        _depositToThirdParty(want.balanceOf(address(this)));

        // Mint our own LP tokens
        _mint(msg.sender, _amount);

        // Reset user debt so he will farm the correct amount
        userBalance = userBalance.add(_amount);
        user.croblancRewardDebt = userBalance.mul(accCroblancPerShare).div(1e18);
        user.wheatRewardDebt = userBalance.mul(accWheatPerShare).div(1e18);

        emit Deposit(msg.sender, _amount);
    }

    function depositAll() public {
        deposit(want.balanceOf(msg.sender));
    }

    function withdraw(uint256 _amount) public nonReentrant whenNotPaused {
        // Reference to this userInfo entry
        UserInfo storage user = userInfo[msg.sender];
        uint256 userBalance = balanceOf(msg.sender);

        require(userBalance > 0);
        require(userBalance >= _amount);

        // Force a harvest
        harvest();

        // User will withdraw?
        if (_amount > 0) {
            // Withdraw funds from MasterChef if needed
            uint256 wantBalance = want.balanceOf(address(this));
            if (wantBalance < _amount) {
                _withdrawFromThirdParty(_amount.sub(wantBalance));
            }

            // Burn our LP token
            _burn(msg.sender, _amount);
            userBalance = balanceOf(msg.sender);

            // Transfer the want back to the user
            want.transfer(msg.sender, _amount);
        }
        // Reset user debt so he will farm the correct amount
        user.croblancRewardDebt = userBalance.mul(accCroblancPerShare).div(1e18);
        user.wheatRewardDebt = userBalance.mul(accWheatPerShare).div(1e18);
        emit Withdraw(msg.sender, _amount);
    }

    function withdrawAll() public {
        withdraw(balanceOf(msg.sender));
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        // In case we mint or burn
        if (from == address(0) || to == address(0)) {
            // Nothing to do
            return;
        }

        UserInfo storage fromUserInfo = userInfo[from];
        UserInfo storage toUserInfo = userInfo[to];

        // Force a harvest for both users
        _harvestOnBehalfOf(from);
        _harvestOnBehalfOf(to);

        // Future user balances
        uint256 fromUserFutureBalance = balanceOf(from).sub(amount);
        uint256 toUserFutureBalance = balanceOf(to).add(amount);

        // Transfer the pending balances and reset users debts
        fromUserInfo.croblancRewardDebt = fromUserFutureBalance.mul(accCroblancPerShare).div(1e18);
        fromUserInfo.wheatRewardDebt = fromUserFutureBalance.mul(accWheatPerShare).div(1e18);
        toUserInfo.croblancRewardDebt = toUserFutureBalance.mul(accCroblancPerShare).div(1e18);
        toUserInfo.wheatRewardDebt = toUserFutureBalance.mul(accWheatPerShare).div(1e18);
    }

    // Withdraw _amount tokens from the third-party Masterchef. We keep the record of stakedWant here, do not interact
    // with the Masterchef from anywhere else in order to keep stakedWant correct.
    function _withdrawFromThirdParty(uint256 _amount) internal {
        if (masterChefEnabled) {
            masterChef.withdraw(masterChefPoolId, _amount);
            stakedWant = stakedWant.sub(_amount);
        }
    }

    // Deposit _amount tokens from the third-party Masterchef. We keep the record of stakedWant here, do not interact
    // with the Masterchef from anywhere else in order to keep stakedWant correct.
    function _depositToThirdParty(uint256 _amount) internal virtual {
        if (masterChefEnabled) {
            masterChef.deposit(masterChefPoolId, _amount);
            stakedWant = stakedWant.add(_amount);
        }
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 userBalance = balanceOf(msg.sender);

        uint256 wantBalance = want.balanceOf(address(this));
        if (wantBalance < userBalance) {
            _withdrawFromThirdParty(userBalance.sub(wantBalance));
        }

        want.transfer(msg.sender, userBalance);

        _burn(msg.sender, userBalance);
        user.croblancRewardDebt = 0;
        user.wheatRewardDebt = 0;

        emit EmergencyWithdraw(msg.sender, userBalance);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function panic() external onlyOwner {
        // Emergency withdraw funds from masterchef and keep safe in the contract
        masterChef.emergencyWithdraw(masterChefPoolId);
        // Pause deposits and withdraws
        _revokeAllowances();
        _pause();
    }

    function _giveAllowances() internal {
        want.approve(address(masterChef), type(uint256).max);
    }

    function _revokeAllowances() internal {
        want.approve(address(masterChef), 0);
    }

    function pause() external onlyOwner {
        _revokeAllowances();
        _pause();
    }

    function unpause() external onlyOwner {
        _giveAllowances();
        _unpause();
    }

    // Enable or disable masterchef rewards at any moment. Owner can update masterchef pool id but not the address.
    function enableMasterChef(uint _poolId) external onlyOwner {
        // Enable
        masterChefEnabled = true;
        masterChefPoolId = _poolId;

        // Deposit into masterchef
        _depositToThirdParty(want.balanceOf(address(this)));
    }

    function disableMasterChef() external onlyOwner {
        // Withdraw from masterchef
        _withdrawFromThirdParty(stakedWant);

        // Masterchef pool id to zero means masterchef is not enabled for us.
        // The Masterchef pool #0 is usually the single staking on the third-party partner.
        masterChefEnabled = false;
        masterChefPoolId = 0;
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        feeRecipient = _feeRecipient;
    }

    function setAlpha(address _alpha) external onlyOwner {
        alpha = CroblancAlpha(_alpha);
    }

    // In case wheat get stuck, but shouldn't happen usually
    function rescueToken(address _token) external onlyOwner {
        // Cannot escape with people's funds
        require(_token != address(want));
        // Rescue the tokens
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }
}
