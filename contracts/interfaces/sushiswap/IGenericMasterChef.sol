// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Give to Caesar what belongs to Caesar, let's call this interface a Sushiswap interface
interface IGenericMasterChef {
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    // Same functions but different names for each platform (original pendingSushi()...)
    function pendingSushi(uint256 _pid, address _user) external view returns (uint256);
    function pendingCrona(uint256 _pid, address _user) external view returns (uint256);
    function pendingVVS(uint256 _pid, address _user) external view returns (uint256);
    function pendingMeerkat(uint256 _pid, address _user) external view returns (uint256);
    function pendingCrow(uint256 _pid, address _user) external view returns (uint256);

    function cronaPerSecond() external view returns (uint256);
    function vvsPerBlock() external view returns (uint256);
    function crowPerBlock() external view returns (uint256); // Not sure, CrowFi did not disclose their source code yet

    // Common functions
    function BONUS_MULTIPLIER() external view returns (uint256);
    function totalAllocPoint() external view returns (uint256);
    function poolLength() external view returns (uint256);
    function poolInfo(uint256 _id) external view returns (address, uint256, uint256, uint256);
    function getMultiplier(uint256 _from, uint256 _to) external view returns (uint256);
    function massUpdatePools() external;
    function updatePool(uint256 _pid) external;
    function deposit(uint256 _pid, uint256 _amount) external;
    function deposit(uint256 _pid, uint256 _amount, address _to) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function enterStaking(uint256 _amount) external;
    function leaveStaking(uint256 _amount) external;
    function emergencyWithdraw(uint256 _pid) external;
}
