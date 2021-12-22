// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./interfaces/cronaswap/IMasterChef.sol";
import "./interfaces/croblanc/ICroblancFarm.sol";
import "./CroblancToken.sol";

//----------------------------------------------------------------------------------------------------------------------
//        _
//       / \      _-'
//     _/|  \-''- _ /
//__-' { |          \        *** CroblancAlpha ***
//    /             \
//    /       "O.  |O }      The Alpha contract contains an unique reference to the treasury
//    |            \ ;       and the dividends contracts.
//                  ',
//       \_         __\      It is also the master control of CROBLANC tokens emission, with
//         ''-_    \.//      the mechanism inspired by the traditional MasterChef template.
//           / '-____'
//          /
//        _'
//      _-'
//----------------------------------------------------------------------------------------------------------------------
contract CroblancAlpha is Ownable, Pausable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // Info of each farm
    struct farmInfo {
        bool registered;
        bool farmingEnabled;
        uint256 allocationPoints;
    }

    struct AddressProposal {
        address newAddress;
        uint256 unlockTimestamp;
    }

    // Info of each
    mapping(address => farmInfo) public farmInfos;
    address[] public farms;
    address public treasury;
    address public dividends;

    AddressProposal public newTreasury;
    AddressProposal public newDividends;

    // Base CROBLANCs to distribute per second. Capped to 0.01
    uint256 public croblancPerSecond;

    // Inflation control, times 100. >100: is a multiplier, <100: is a divider. Capped to 10000 (100 times 100) or 20000 during full moons
    uint256 public emissionMultiplier;

    // Performance fee charged per thousand, hard capped to 250 (25%)
    uint256 public performanceFeePerThousand;

    // Sum of allocation points of all farms
    uint256 public totalAllocationPoints;

    event NewTreasuryProposed(address indexed newAddress, uint256 unlockTime);
    event NewTreasuryDeployed(address indexed newAddress);
    event NewDividendsProposed(address indexed newAddress, uint256 unlockTime);
    event NewDividendsDeployed(address indexed newAddress);

    constructor (
        address _treasury,
        address _dividends,
        uint256 _croblancPerSecond,
        uint256 _emissionMultiplier,
        uint256 _performanceFeePerThousand
    ) public {
        treasury = _treasury;
        dividends = _dividends;
        setCroblancPerSecond(_croblancPerSecond, true);
        setEmissionMultiplier(_emissionMultiplier, true);
        performanceFeePerThousand = _performanceFeePerThousand;
    }

    function getReward(address _farm, uint256 _from, uint256 _to) public view returns (uint256) {
        if (!farmInfos[_farm].farmingEnabled || _from == 0) {
            return 0;
        }

        uint256 multiplier = _to.sub(_from).mul(emissionMultiplier).div(100);
        uint256 globalReward = multiplier.mul(croblancPerSecond);

        // example with 1000 CROBLANC total for a pool with 500 allocations points over a total of 1500
        // mul(1e12) and div(1e12) in order to prevent integer rounding issues
        //      farmReward = globalReward.mul(1e12).div(totalAllocationPoints).mul(farmInfos[_farm].allocationPoints).div(1e12);
        //      farmReward =      1000   .mul(1e12).div(         1500        ).mul(                500              ).div(1e12)
        //      farmReward = ((1000e12 / 1500) * 500) / 1e12
        //      farmReward = 666666666667 * 500 / 1e12
        //      farmReward = 333333333333333 / 1e12
        //      farmReward = 333
        uint256 farmReward = globalReward.mul(1e12).div(totalAllocationPoints).mul(farmInfos[_farm].allocationPoints).div(1e12);

        return farmReward;
    }

    function isFullMoon() public view returns (bool) {
        // Data until end of 2025, after that there will be no moon boost over >100x multiplier anymore.
        uint32[50] memory fullMoonDays = [
            1639785600, 1642377600, 1644969600, 1647561600, 1650067200, 1652572800, 1655164800, 1657670400, 1660176000,
            1662768000, 1665273600, 1667865600, 1670371200, 1672963200, 1675555200, 1678147200, 1680652800, 1683244800,
            1685750400, 1688342400, 1690848000, 1693353600, 1695945600, 1698451200, 1701043200, 1703548800, 1706140800,
            1708732800, 1711324800, 1713830400, 1716422400, 1718928000, 1721520000, 1724025600, 1726531200, 1729123200,
            1731628800, 1734220800, 1736726400, 1739318400, 1741910400, 1744416000, 1747008000, 1749600000, 1752105600,
            1754697600, 1757203200, 1759708800, 1762300800, 1764806400
        ];
        for (uint32 i = 0; i < fullMoonDays.length ; i++) {
            if (block.timestamp >= fullMoonDays[i] && block.timestamp <= fullMoonDays[i] + 86400) {
                return true;
            }
        }
        return false;
    }

    function getFarmIndexByAddress(address _farm) public view returns (uint256) {
        for (uint256 i = 0; i < farms.length; i++) {
            if (farms[i] == _farm) {
                return i;
            }
        }
        revert();
    }

    function getFarms() external view returns (address[] memory) {
        return farms;
    }

    function farmsLength() external view returns (uint256) {
        return farms.length;
    }
    
    function addFarm(address _farm, uint256 _allocationPoints) external onlyOwner {
        require(!farmInfos[_farm].registered);

        // Register the pool data in the mapping
        farmInfos[_farm].registered = true;

        // Also add in the global array
        farms.push(_farm);

        // Enable farming + give points
        enableFarming(_farm, _allocationPoints);
    }
    
    function removeFarm(address _farm) external onlyOwner {
        require(farmInfos[_farm].registered);

        // Gracefully delete the mapping entry
        if (farmInfos[_farm].farmingEnabled) {
            // Disable farming if still enabled
            disableFarming(_farm);
        }

        // Should never happen, just in case
        if (farmInfos[_farm].allocationPoints > 0) {
            // Remove allocation points
            amendAllocationPoints(_farm, 0);
        }

        // Null the remaining data
        farmInfos[_farm].registered = false;
        delete farmInfos[_farm];

        // Also remove from farms array
        uint256 index = getFarmIndexByAddress(_farm);
        farms[index] = farms[farms.length-1];
        farms.pop();
    }
    
    function amendAllocationPoints(address _farm, uint256 _allocationPoints) public onlyOwner {
        require(farmInfos[_farm].registered);

        uint256 allocationPointsBefore = farmInfos[_farm].allocationPoints;
        if (allocationPointsBefore == _allocationPoints) {
            return;
        }

        farmInfos[_farm].allocationPoints = _allocationPoints;
        totalAllocationPoints = totalAllocationPoints.sub(allocationPointsBefore).add(_allocationPoints);
    }

    function disableFarming(address _farm) public onlyOwner {
        require(farmInfos[_farm].registered);
        require(farmInfos[_farm].farmingEnabled);

        // Harvest rewards one last time
        ICroblancFarm(farms[getFarmIndexByAddress(_farm)]).updatePool(false);

        // Then disable the farming
        amendAllocationPoints(_farm, 0);
        farmInfos[_farm].farmingEnabled = false;
    }
    
    function enableFarming(address _farm, uint256 _allocationPoints) public onlyOwner {
        require(farmInfos[_farm].registered);
        require(!farmInfos[_farm].farmingEnabled);

        farmInfos[_farm].farmingEnabled = true;
        amendAllocationPoints(_farm, _allocationPoints);
    }

    function _massUpdateFarms(uint256 _from, uint256 _to) internal {
        // Beware of gas exhaustion, if we are over gas limit we must disable some farms first or call two or more
        // transactions with a part of the range.
        for (uint256 i = _from; i < _to; i++) {
            if (farmInfos[farms[i]].farmingEnabled) {
                ICroblancFarm(farms[i]).updatePool(false);
            }
        }
    }

    function setCroblancPerSecond(uint256 _croblancPerSecond, bool _updateFarms) public onlyOwner {
        // maximum base speed: 0.031709791983764590 CROBLANC / sec
        // maximum multiplier: 100
        //             equals: 3.1709791983764590 CROBLANC / sec
        //                     = 273972.6027397260576 CROBLANC / day
        //                     = 100M CROBLANC / 1 year
        require(_croblancPerSecond <= 31709791983764590, "Over hard cap");

        // Harvest one last time before updating the farming settings
        if (_updateFarms) {
            _massUpdateFarms(0, farms.length);
        }

        // Update the emission
        croblancPerSecond = _croblancPerSecond;
    }

    // Amend the treasury is delayed by 7 days to avoid any abuse of authority
    function proposeNewTreasury(address _newTreasuryAddress) external onlyOwner {
        // Save proposal
        newTreasury.unlockTimestamp = block.timestamp + 604800;
        newTreasury.newAddress = _newTreasuryAddress;

        // Alert everybody
        emit NewTreasuryProposed(_newTreasuryAddress, newTreasury.unlockTimestamp);
    }

    function deployNewTreasury() external onlyOwner {
        // Access control
        require(newTreasury.unlockTimestamp > 0);
        require(newTreasury.unlockTimestamp <= block.timestamp);

        // Update Treasury
        treasury = newTreasury.newAddress;

        // Reset proposal
        newTreasury.newAddress = address(0);
        newTreasury.unlockTimestamp = 0;

        // Alert everybody
        emit NewTreasuryDeployed(newTreasury.newAddress);
    }

    // Amend the treasury is delayed by 7 days to avoid any abuse of authority
    function proposeNewDividends(address _newDividendsAddress) external onlyOwner {
        // Save proposal
        newDividends.unlockTimestamp = block.timestamp + 604800;
        newDividends.newAddress = _newDividendsAddress;

        // Alert everybody
        emit NewDividendsProposed(_newDividendsAddress, newDividends.unlockTimestamp);
    }

    function deployNewDividends() external onlyOwner {
        // Access control
        require(newDividends.unlockTimestamp > 0);
        require(newDividends.unlockTimestamp <= block.timestamp);

        // Update Dividends
        dividends = newDividends.newAddress;

        // Reset proposal
        newDividends.newAddress = address(0);
        newDividends.unlockTimestamp = 0;

        // Alert everybody
        emit NewDividendsDeployed(newDividends.newAddress);
    }

    function setEmissionMultiplier(uint256 _emissionMultiplier, bool _updateFarms) public onlyOwner {
        // Maximum of x200 (during full moon)
        require(_emissionMultiplier <= 20000, "Too high");

        if (!isFullMoon()) {
            // After full, maximum will is capped to x100

            // Potential abuse of authority: if Owner doesn't lower the emissionMultiplier after the full moon ends, a
            // x200 multiplier may run longer than expected. We do not want the users to pay gas for massUpdateFarms,
            // so we will handle this with cron jobs and do our best to keep a full moon booster duration around 24h.
            require(_emissionMultiplier <= 10000, "Not full moon");
        }

        // Supposed to be always true. Just keep the option in cause we have an out of gas and let the admin update
        // the pools manually
        if (_updateFarms) {
            // Harvest one last time before updating the farming settings
            _massUpdateFarms(0, farms.length);
        }

        // Update the multiplier
        emissionMultiplier = _emissionMultiplier;
    }

    function massUpdateFarmsPartly(uint256 _from, uint256 _to) external onlyOwner {
        _massUpdateFarms(_from, _to);
    }

    function setPerformanceFeePerThousand(uint256 _performanceFeePerThousand) public onlyOwner {
        // Hard cap of 25% to prevent any abuse of authority.
        require(_performanceFeePerThousand <= 250);

        performanceFeePerThousand = _performanceFeePerThousand;
    }
}
