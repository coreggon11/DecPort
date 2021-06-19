pragma solidity >=0.8.0;

import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

library RibeUtils {

    function uint16ArraySum(uint16[] memory array) external pure returns (uint) {
        uint output = 0;
        for(uint i = 0; i < array.length; ++i){
            output += array[i];
        }
        return output;
    }

    // max of two numbers
    function max(uint a, uint b) external pure returns (uint) {
        return a > b ? a : b;
    }

    // overflow safe subtraction
    function sub(uint a, uint b) external pure returns (uint) {
        require(a > b, "Math Error: Overflow");
        return a - b;
    }

    // overflow safe addition
    function add(uint a, uint b) external pure returns (uint) {
        uint out = a + b;
        require((out > a && out > b) || (a == 0) || (b == 0), "Math Error: Overflow");
        return out;
    }

    // overflow safe multiplication
    function mul(uint a, uint b) external pure returns (uint) {
        if(a == 0 || b == 0) {
            return 0;
        }
        uint out = a * b;
        require(out / b == a, "Math Error: Overflow");
        return out;
    }

    // zero safe division
    function div(uint a, uint b) external pure returns (uint) {
        require(b != 0, "Math Error: Dividing by zero");
        return a / b;
    }

    /*
    returns how much is 'b' percent of 'a'
    Ribe uses 2 floating points for percentages, so 100% = 10 000 so we can get e.g 0.01%  
     */
    function percent(uint a, uint b) external pure returns (uint) {
        if(a == 0 || b == 0) {
            return 0;
        }
        uint first = a * b;
        require(first / b == a, "Math Error: Overflow");
        return first / 10000;
    }

    function getFactoryAddress() public pure returns (address) {
        return 0xad4B42D933789eE7dd7669C442FD7c7992B9F3F5;
    }

    function getWethAddress() public pure returns (address) {
        return 0xd6CDe95de4BDd0BB4f16Bf3A20E636D083867880;
    }

    function getDaiAddress() public pure returns (address) {
        return 0xcD8A92285d51Fbb8aC92312691CaDF956e3774D2;
    }

    function getRouterAddress() public pure returns (address) {
        return 0x6559dE5E9A651a37d21150816ba0D256C3143D37;
    }

    function pairInfo(address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB, uint totalSupply) {
        IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(getFactoryAddress(), tokenA, tokenB));
        totalSupply = pair.totalSupply();
        (uint reserves0, uint reserves1,) = pair.getReserves();
        (reserveA, reserveB) = (tokenA == pair.token0() ? (reserves0, reserves1) : (reserves1, reserves0));
    }

    function getDaiWethPath() external pure returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = getDaiAddress();
        path[1] = getWethAddress();
        return path;
    }

    // how much eth I get for 1 token
    function tokenPriceEther(address tokenAddress) external view returns (uint) {
        (uint reserveToken, uint reserveWeth, ) = pairInfo(tokenAddress, getWethAddress());
        ERC20 theToken = ERC20(tokenAddress);
        return UniswapV2Library.getAmountOut(10 ** theToken.decimals(), reserveToken, reserveWeth);
    }

    // return ether price in usdt
    function ethPrice() external view returns (uint) {
        (uint reserveDai, uint reserveWeth, ) = pairInfo(getDaiAddress(), getWethAddress());
        return UniswapV2Library.getAmountOut(10 ** 18, reserveWeth, reserveDai);
    }

    // return min eth recieved for 'amountDai' dai with 1% slippage
    function getMinEthForDaiWithSlippage(uint amountDai) external view returns (uint) {
        (uint reserveDai, uint reserveWeth, ) = pairInfo(getDaiAddress(), getWethAddress());

        uint amount = UniswapV2Library.getAmountOut(amountDai, reserveDai, reserveWeth);
        if(amount == 0) {
            return 0;
        }
        uint perc = 9900;
        uint out = amount * perc;
        require(out / perc == amount, "Math Error: Overflow");
        return out / 10000;
    }

}