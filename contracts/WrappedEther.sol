pragma solidity >= 0.6.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WrappedEther is ERC20 {

    constructor () ERC20("Wrapped Ether","WETH") public {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

}