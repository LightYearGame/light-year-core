// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// File: contracts/LGEWhitelisted.sol
contract LGEWhitelisted is Ownable {

    using SafeMath for uint256;

    struct WhitelistRound {
        uint256 duration;
        uint256 amountMax;
        mapping(address => bool) addresses;
        mapping(address => uint256) purchased;
    }

    WhitelistRound[] public _lgeWhitelistRounds;

    uint256 public _lgeTimestamp;
    address public _lgePairAddress;

    constructor () internal {
    }

    function getOwner() public view returns (address) {
        return owner();
    }

    function createLGEWhitelist(address pairAddress, uint256[] calldata durations, uint256[] calldata amountsMax) external onlyOwner() {
        require(durations.length == amountsMax.length, "Invalid whitelist(s)");

        _lgePairAddress = pairAddress;

        if(durations.length > 0) {

            delete _lgeWhitelistRounds;

            for (uint256 i = 0; i < durations.length; i++) {
                _lgeWhitelistRounds.push(WhitelistRound(durations[i], amountsMax[i]));
            }
        }
    }
    
    function modifyLGEWhitelist(uint256 index, uint256 duration, uint256 amountMax, address[] calldata addresses, bool enabled) external onlyOwner() {
        require(index < _lgeWhitelistRounds.length, "Invalid index");
        require(amountMax > 0, "Invalid amountMax"); // seems like an unnecessary require statement

        if(duration != _lgeWhitelistRounds[index].duration) {
            _lgeWhitelistRounds[index].duration = duration;
        }

        if(amountMax != _lgeWhitelistRounds[index].amountMax) {
            _lgeWhitelistRounds[index].amountMax = amountMax;
        }

        for (uint256 i = 0; i < addresses.length; i++) {
            _lgeWhitelistRounds[index].addresses[addresses[i]] = enabled;
        }
    }

    function getLGEWhitelistRound() public view returns (uint256, uint256, uint256, uint256, bool, uint256) {

        if(_lgeTimestamp > 0) {

            uint256 wlCloseTimestampLast = _lgeTimestamp;

            for (uint256 i = 0; i < _lgeWhitelistRounds.length; i++) {

                WhitelistRound storage wlRound = _lgeWhitelistRounds[i];

                wlCloseTimestampLast = wlCloseTimestampLast.add(wlRound.duration);
                if(now <= wlCloseTimestampLast) {
                    return (i.add(1), wlRound.duration, wlCloseTimestampLast, wlRound.amountMax, wlRound.addresses[_msgSender()], wlRound.purchased[_msgSender()]);
                }
            }

        }

        return (0, 0, 0, 0, false, 0);
    }

    function _applyLGEWhitelist(address sender, address recipient, uint256 amount) internal {

        require(_lgeWhitelistRounds.length > 0, "No whitelist rounds defined");
        require(_lgePairAddress != address(0), "Pair address not defined");

        if(_lgeTimestamp == 0 && sender != _lgePairAddress && recipient == _lgePairAddress && amount > 0) {
            _lgeTimestamp = now;
        }

        if(sender == _lgePairAddress && recipient != _lgePairAddress) {
            (uint256 wlRoundNumber,,,,,) = getLGEWhitelistRound();

            if(wlRoundNumber > 0) { 

                WhitelistRound storage wlRound = _lgeWhitelistRounds[wlRoundNumber.sub(1)];

                require(wlRound.addresses[recipient], "LGE - Buyer is not whitelisted");

                uint256 amountRemaining = 0;

                if(wlRound.purchased[recipient] < wlRound.amountMax) {
                    amountRemaining = wlRound.amountMax.sub(wlRound.purchased[recipient]);
                }

                require(amount <= amountRemaining, "LGE - Amount exceeds whitelist maximum");
                wlRound.purchased[recipient] = wlRound.purchased[recipient].add(amount);
            }
        }
    }

}

// File: contracts/LightCoin.sol
contract LightCoin is ERC20("Light Coin", "LC"), LGEWhitelisted {

    constructor() public {
        _mint(_msgSender(), 1e26);  // 100 million, 18 decimals
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override virtual {
        LGEWhitelisted._applyLGEWhitelist(sender, recipient, amount);
        ERC20._transfer(sender, recipient, amount);
    }

    function burn(uint256 _amount) external {
        _burn(_msgSender(), _amount);
    }
}
