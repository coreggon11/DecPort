pragma solidity >= 0.6.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dai is ERC20 {

    constructor () ERC20("DAI","DAI") public {
        _mint(msg.sender, 2500000000 * 10 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

}