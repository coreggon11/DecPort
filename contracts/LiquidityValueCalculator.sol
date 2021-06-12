pragma solidity >=0.6.6;

import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';

contract LiquidityValueCalculator {

    using SafeMath for uint;

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

    function tokenPriceInEther(address tokenAddress) public view returns (uint) {
        (uint tokenReserve, uint wEthReserve,) = pairInfo(tokenAddress, wethAddress);
        require(tokenReserve > 0, "No token reserves");
        return wEthReserve / tokenReserve;
    }

    function ethPrice() public view returns (uint) {
        (uint usdtReserve, uint wEthReserve,) = pairInfo(usdtAddress, wethAddress);
        require(wEthReserve > 0, "No weth reserves");
        return usdtReserve / wEthReserve;
    }

}