pragma solidity >=0.6.6;

import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RibeUniSwapUtils {

    address public factory;
    address public routerAddress;
    address public wethAddress;
    address public usdtAddress;

    constructor(address factory_, address routerAddress_, address weth, address usdt) public {
        factory = factory_;
        routerAddress = routerAddress_;
        wethAddress = weth;
        usdtAddress = usdt;
    }

    function pairInfo(address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB, uint totalSupply) {
        IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(factory, tokenA, tokenB));
        totalSupply = pair.totalSupply();
        (uint reserves0, uint reserves1,) = pair.getReserves();
        (reserveA, reserveB) = tokenA == pair.token0() ? (reserves0, reserves1) : (reserves1, reserves0);
    }

    // how much eth I get for 1 token
    function tokenPriceEther(address tokenAddress) public view returns (uint) {
        (uint reserveToken, uint reserveWeth, ) = pairInfo(tokenAddress, wethAddress);
        ERC20 theToken = ERC20(tokenAddress);
        return UniswapV2Library.getAmountOut(10 ** theToken.decimals(), reserveToken, reserveWeth);
    }

    // return ether price in usdt
    function ethPrice() public view returns (uint) {
        (uint reserveUsd, uint reserveWeth, ) = pairInfo(usdtAddress, wethAddress);
        return UniswapV2Library.getAmountOut(10 ** 18, reserveWeth, reserveUsd);
    }

}