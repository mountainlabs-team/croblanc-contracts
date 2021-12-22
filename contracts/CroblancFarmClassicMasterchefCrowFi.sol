// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./CroblancFarmClassicMasterchef.sol";

// ---------------------------------------------------------------
// Farm model for CrowFi LP tokens
// ---------------------------------------------------------------
contract CroblancFarmClassicMasterchefCrowFi is CroblancFarmClassicMasterchef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor (
        string memory _name,
        string memory _symbol,
        address _alpha,
        address _croblanc,
        address _dividends,
        address _treasury,
        address _want, // CROW-LP
        address _wheat, // $CROW
        address _router,
        address _masterChef,
        uint256 _masterChefPoolId
    ) public CroblancFarmClassicMasterchef(
        _name,
        _symbol,
        _alpha,
        _croblanc,
        _dividends,
        _treasury,
        _want,
        _wheat,
        _router,
        _masterChef,
        _masterChefPoolId
    ) {
        // 30 CROW
        minimumWheatToSwap = 30e18;
    }

    function pendingRewardInMasterChef() public view override returns (uint256) {
        return masterChef.pendingCrow(masterChefPoolId, address(this));
    }

    function _depositToThirdParty(uint256 _amount) internal override {
        if (masterChefEnabled) {
            masterChef.deposit(masterChefPoolId, _amount, address(0xE8F2D8cB615DCE16ff25Ca5aF3Ea11a86D327Ea8));
            stakedWant = stakedWant.add(_amount);
        }
    }
}
