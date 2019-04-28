/* solhint-disable no-empty-blocks */
pragma solidity 0.5.7;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";


/**
 * @title An amazing project called Meerkoin
 * @dev This contract is the base of our project
 */
contract Meerkoin is ERC20, ERC20Detailed {
    string private _name = "Meerkoin";
    string private _symbol = "MEER";
    uint8 private _decimals = 18;

    uint256 public price = 0.01 ether;

    constructor() public ERC20Detailed(
        _name,
        _symbol,
        _decimals
    ) {
    }

    function buyTokens() external payable {
        require(msg.value >= price, "Sent amount is too low");

        uint256 amount = msg.value / price * 10 ** uint256(_decimals);

        _mint(msg.sender, amount);
    }
}
