// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./../interface/ICommodityERC20.sol";
import "./../interface/IRegistry.sol";

contract CommodityERC20 is ERC20 {
    using SafeMath for uint256;

    //registry
    address public registryAddress;

    //only operator
    modifier onlyOperator(){
        require(registry().isOperator(msg.sender), "onlyOperator: require operator.");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        address registry_
    ) public ERC20(name, symbol) {
        registryAddress = registry_;
    }

    function registry() private view returns (IRegistry){
        return IRegistry(registryAddress);
    }

    function operatorTransfer(address sender_, address recipient_, uint256 amount_) public onlyOperator {
        _transfer(sender_, recipient_, amount_);
    }

    function mint(address to_, uint256 amount_) public onlyOperator {
        _mint(to_, amount_);
    }

    function burn(uint256 amount_) public {
        _burn(_msgSender(), amount_);
    }
}
