// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//----------------------------------------------------------------------------------------------------------------------
//        _
//       / \      _-'        *** CroblancToken ***
//     _/|  \-''- _ /
//__-' { |          \        Croblanc is just a classic and simple ERC20 Token.
//    /             \
//    /       "O.  |O }      Hard supply cap: 100,000,000 CROBLANC
//    |            \ ;
//                  ',       After the initial release of Croblanc, adding new minters (farms) require a 24 hours notice
//       \_         __\      to avoid any abuse of authority. Everyone can monitor the blockchain and see that a new
//         ''-_    \.//      minter will be added soon.
//           / '-____'
//          /                Burned tokens can be minted again unless they are burned using the burnForever() function.
//        _'
//      _-'
//----------------------------------------------------------------------------------------------------------------------
contract CroblancToken is ERC20, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct MinterInfo {
        bool enabled;
        uint256 activationTimestamp;
    }

    uint256 public maxTotalSupply; // 100,000,000 max
    uint256 public minimumActivationDelay;
    mapping (address => MinterInfo) public minters;

    event NewMinterProposed(address _address, uint256 _activationTimestamp);
    event NewMinterAdded(address _address);
    event MinterRemoved(address _address);

    modifier onlyMinter() {
        require(minters[msg.sender].enabled);
        require(minters[msg.sender].activationTimestamp <= block.timestamp);
        _;
    }

    constructor (string memory _name, string memory _symbol) public ERC20(_name, _symbol) {
        maxTotalSupply = 100000000 * 1e18;

        // 1 CROBLANC will be pre-minted for the initial dividend reserve
        _mint(msg.sender, 1e18);
    }

    function mint(address _to, uint256 _amount) public onlyMinter returns (uint256) {
        require(_amount.add(totalSupply()) <= maxTotalSupply);

        _mint(_to, _amount);

        return _amount;
    }

    function safeMint(address _to, uint256 _amount) external onlyMinter returns (uint256) {
        if (_amount.add(totalSupply()) > maxTotalSupply) {
            return mint(_to, maxTotalSupply.sub(totalSupply()));
        }
        return mint(_to, _amount);
    }

    // Adding a minter must be done with a 24 hours notice in order to avoid any abuse of authority.
    function proposeNewMinter(address _newMinter) external onlyOwner {
        uint256 activationTimestamp = block.timestamp + minimumActivationDelay;
        minters[_newMinter].activationTimestamp = activationTimestamp;
        emit NewMinterProposed(_newMinter, activationTimestamp);
    }

    // Enable a minter after the 24 hours notice period has passed.
    function enableNewMinter(address _minter) external onlyOwner {
        require(minters[_minter].activationTimestamp > 0);
        require(minters[_minter].activationTimestamp <= block.timestamp);

        minters[_minter].enabled = true;

        emit NewMinterAdded(_minter);
    }

    // Immediately remove a minter.
    function removeMinter(address _minter) external onlyOwner {
        minters[_minter].enabled = false;
        minters[_minter].activationTimestamp = 0;
        delete minters[_minter];

        emit MinterRemoved(_minter);
    }

    // Only during initial deployment. Will not work after calling postDeploymentLockMinters()
    function addMinter(address _minter) external onlyOwner {
        require(minimumActivationDelay == 0);

        minters[_minter].enabled = true;
        minters[_minter].activationTimestamp = block.timestamp;

        emit NewMinterAdded(_minter);
    }

    // It is possible to add minters instantly upon initial deployment to make the process easier.
    // But after this function is called, it will not possible to mind without waiting a 24 hours notice.
    function postDeploymentLockMinters() external onlyOwner {
        require(minimumActivationDelay == 0);
        minimumActivationDelay = 86400;
    }

    // With the simple burn function, the burned tokens can be minted again by our liquidity mining incentives
    function burn(uint256 _amount) external {
        _burn(msg.sender, _amount);
    }

    // The burnForever function burns but also reduce the maximum supply forever!
    function burnForever(uint256 _amount) external {
        _burn(msg.sender, _amount);
        maxTotalSupply = maxTotalSupply.sub(_amount);
    }

    // Admin helper for people who send tokens on the contract address, this contract address should not host any fund.
    function tokenRecovery(address _token) external onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender, amount);
    }
}
