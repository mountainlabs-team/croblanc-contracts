// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./CroblancFarmClassicMasterchef.sol";

// ---------------------------------------------------------------
// Farm model for VVSFinance LP tokens
// ---------------------------------------------------------------
contract CroblancFarmClassicMasterchefVVSFinance is CroblancFarmClassicMasterchef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor (
        string memory _name,
        string memory _symbol,
        address _alpha,
        address _croblanc,
        address _dividends,
        address _treasury,
        address _want, // VVP-LP
        address _wheat, // $VVS
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
        // 50,000 VVS
        minimumWheatToSwap = 50000e18;
    }

    function pendingRewardInMasterChef() public view override returns (uint256) {
        return masterChef.pendingVVS(masterChefPoolId, address(this));
    }
}
