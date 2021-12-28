// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./CroblancFarmClassicMasterchefV3.sol";

// ---------------------------------------------------------------
// Farm model for CrowFi LP tokens
// ---------------------------------------------------------------
contract CroblancFarmClassicMasterchefV3CrowFi is CroblancFarmClassicMasterchefV3 {

    constructor (
        string memory _name,
        string memory _symbol,
        address _alpha,
        address _croblanc,
        address _feeRecipient,
        address _want, // Crow-LP
        address _wheat, // $CROW
        address _masterChef,
        uint256 _masterChefPoolId
    ) public CroblancFarmClassicMasterchefV3 (
        _name,
        _symbol,
        _alpha,
        _croblanc,
        _feeRecipient,
        _want,
        _wheat,
        _masterChef,
        _masterChefPoolId
    ) {
    }

    function pendingRewardInMasterChef() public view override returns (uint256) {
        return masterChef.pendingCrow(masterChefPoolId, address(this));
    }

    function _depositToThirdParty(uint256 _amount) internal override {
        if (masterChefEnabled) {
            masterChef.deposit(masterChefPoolId, _amount, feeRecipient);
            stakedWant = stakedWant.add(_amount);
        }
    }
}
