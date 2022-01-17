// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./../interface/ICommodityERC20.sol";
import "./../interface/IRegistry.sol";

import "../common/PreMintable.sol";

contract CommodityERC20 is ERC20, ICommodityERC20, PreMintable {

    address public registry;

    constructor(
        string memory name,
        string memory symbol,
        address registry_
    ) public ERC20(name, symbol) {
        registry = registry_;
    }

    // Only for premint. Check PreMintable.sol
    function mint(address to_, uint256 amount_) external onlyForPreMint {
        _mint(to_, amount_);
    }

    // Currently staking.sol (in light-year-core) and explore.sol (in light-year-battle) can mint.
    function mintByInternalContracts(address to_, uint256 amount_) external override {
        require(IRegistry(registry).canMintCommodity(_msgSender()), "Access denied");
        _mint(to_, amount_);
    }

    function burn(uint256 amount_) external override {
        _burn(_msgSender(), amount_);
    }
}
