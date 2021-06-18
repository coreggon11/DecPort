pragma solidity >=0.6.6;

import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./RibeUtils.sol";

contract RibeUniSwapUtils {

    using RibeUtils for uint;

    address public factory;
    address public routerAddress;
    address public wethAddress;
    address public daiAddress;

    constructor(address factory_, address routerAddress_, address weth, address dai) public {
        factory = factory_;
        routerAddress = routerAddress_;
        wethAddress = weth;
        daiAddress = dai;
    }

    function pairInfo(address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB, uint totalSupply) {
        IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(factory, tokenA, tokenB));
        totalSupply = pair.totalSupply();
        (uint reserves0, uint reserves1,) = pair.getReserves();
        (reserveA, reserveB) = tokenA == pair.token0() ? (reserves0, reserves1) : (reserves1, reserves0);
    }

    function getDaiWethPath() public view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = daiAddress;
        path[1] = wethAddress;
        return path;
    }

    // how much eth I get for 1 token
    function tokenPriceEther(address tokenAddress) public view returns (uint) {
        (uint reserveToken, uint reserveWeth, ) = pairInfo(tokenAddress, wethAddress);
        ERC20 theToken = ERC20(tokenAddress);
        return UniswapV2Library.getAmountOut(10 ** theToken.decimals(), reserveToken, reserveWeth);
    }

    // return ether price in usdt
    function ethPrice() public view returns (uint) {
        (uint reserveDai, uint reserveWeth, ) = pairInfo(daiAddress, wethAddress);
        return UniswapV2Library.getAmountOut(10 ** 18, reserveWeth, reserveDai);
    }

    // return min eth recieved for 'amountDai' dai with 1% slippage
    function getMinEthForDaiWithSlippage(uint amountDai) public view returns (uint) {
        (uint reserveDai, uint reserveWeth, ) = pairInfo(daiAddress, wethAddress);
        return RibeUtils.percent(UniswapV2Library.getAmountOut(amountDai, reserveDai, reserveWeth), 9900);
    }

}