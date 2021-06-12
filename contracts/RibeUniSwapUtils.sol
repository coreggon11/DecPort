pragma solidity >=0.6.6;

import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';

contract RibeUniSwapUtils {

    address public factory;
    address public wethAddress;
    address public usdtAddress;

    constructor(address factory_, address weth, address usdt) public {
        factory = factory_;
        wethAddress = weth;
        usdtAddress = usdt;
    }

    function pairInfo(address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB, uint totalSupply) {
        IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(factory, tokenA, tokenB));
        totalSupply = pair.totalSupply();
        (uint reserves0, uint reserves1,) = pair.getReserves();
        (reserveA, reserveB) = tokenA == pair.token0() ? (reserves0, reserves1) : (reserves1, reserves0);
    }

    // return token price in ether with 18 floating numbers precision
    function tokenPriceInEther(address tokenAddress) public view returns (uint) {
        (uint tokenReserve, uint wEthReserve,) = pairInfo(tokenAddress, wethAddress);
        require(tokenReserve > 0, "No token reserves");
        return (wEthReserve * 10 ** 18) / tokenReserve;
    }

    // return token price in usdt with 22 floating numbers precision
    function tokenPriceInUsdt(address tokenAddress) public view returns (uint) {
        return tokenPriceInEther(tokenAddress) * ethPrice();
    }

    // return ether price in USDT with 4 floating numbers precision
    function ethPrice() public view returns (uint) {
        (uint usdtReserve, uint wEthReserve,) = pairInfo(usdtAddress, wethAddress);
        require(wEthReserve > 0, "No weth reserves");
        return (usdtReserve * 10000) / wEthReserve;
    }

}