pragma solidity >= 0.6.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RandomToken is ERC20 {

    constructor () ERC20("RandomToken","RANDOM") public {
        _mint(msg.sender, 5000000000 * 10 ** decimals());
    }

}