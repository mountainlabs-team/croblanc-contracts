// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./CroblancFarmClassicMasterchef.sol";

// ---------------------------------------------------------------
// Farm model for CronaSwap LP tokens
// ---------------------------------------------------------------
contract CroblancFarmClassicMasterchefCronaswap is CroblancFarmClassicMasterchef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor (
        string memory _name,
        string memory _symbol,
        address _alpha,
        address _croblanc,
        address _dividends,
        address _treasury,
        address _want, // Crona-LP
        address _wheat, // $CRONA
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
        // 3 CRONA
        minimumWheatToSwap = 3e18;
    }

    function pendingRewardInMasterChef() public view override returns (uint256) {
        return masterChef.pendingCrona(masterChefPoolId, address(this));
    }
}
