pragma solidity >= 0.6.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UsdTether is ERC20 {

    constructor () ERC20("USD Tether","USDT") public {
        _mint(msg.sender, 2500000000 * 10 ** decimals());
    }

}