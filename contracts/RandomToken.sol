pragma solidity >= 0.6.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RandomToken is ERC20 {

    constructor (string memory name_, string memory symbol_) ERC20(name_, symbol_) public {
        _mint(msg.sender, 5000000000 * 10 ** decimals());
    }

}