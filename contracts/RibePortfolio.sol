pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";

import "./RibeUtils.sol";

contract RibePortfolio is Ownable {

    using RibeUtils for uint;

    bool private isPublic;
    bool private isDynamic;
    Share[] private shares;

    modifier allowedInvestor(address investor) {
        require(canInvest(investor), "Ribe Protocol: User can not invest in this portfolio!");
        _;
    }

    struct Share {
        address tokenAddress;   // address of the token
        uint16 share;           // share of the token in %
    }

    constructor (bool isPublic_, bool isDynamic_, address[] memory addresses_, uint16[] memory shares_) Ownable() public {
        isPublic = isPublic_;
        isDynamic = isDynamic_;
        for(uint i = 0; i < addresses_.length; ++i) {
            shares.push(Share(addresses_[i], shares_[i]));
        }
    }

    function investDai(address investor, uint amountDai, uint wethTransferred)
        external allowedInvestor(investor) {
        if(isDynamic) {
            investDaiDynamic(investor, amountDai, wethTransferred);
        } else {
            investDaiStatic(investor, amountDai, wethTransferred);
        }
    }

    function investWeth(address investor, uint wethTransferred) 
        external allowedInvestor(investor) {
        if(isDynamic) {
            investWethDynamic(investor, wethTransferred);
        } else {
            investWethStatic(investor, wethTransferred);
        }
    }

    function investDaiStatic(address investor, uint amountDai, uint wethTransferred) private {
        // dai is already here, we don't need to convert
        uint sharesWithoutDai = RibeUtils.sub(10000, daiShare());
        uint wethLeft = wethTransferred;
        IERC20 weth = IERC20(RibeUtils.getWethAddress());
        // approve weth
        weth.approve(RibeUtils.getRouterAddress(), wethTransferred);
        for(uint i; i < shares.length; ++i) {
            uint shareOfWeth = (uint) (shares[i].share).percent(sharesWithoutDai);
            // actual share with dai
            uint wethToSwap = wethTransferred.percent(shareOfWeth);
            wethLeft = wethLeft.sub(wethToSwap);
            if(shares[i].tokenAddress == RibeUtils.getWethAddress()){
                // we do not need to swap weth obviously
                continue;
            }
            // TODO swap weth to token
        }
        // TODO mint tokens
        // TODO send tokens to investor
        // TODO send tokens to contract owner
    }

    function investDaiDynamic(address investor, uint amountDai, uint wethTransferred) private {
        // TODO
    }

    function investWethStatic(address investor, uint wethTransferred) private {
       // TODO
    }

    function investWethDynamic(address investor, uint wethTransferred) private {
       // TODO
    }

    /* 
    if the portfolio contains DAI address, 
    this function returns how much of amountDai invested should not be converted to weth
    */
    function amountDaiInPortfolio(uint amountDai, address daiAddress) public view returns (uint) {
        return amountDai.percent(daiShare());
    }

    function daiShare() public view returns (uint16 share) {
        share = 0;
        for(uint i = 0; i < shares.length; ++i) {
            if(shares[i].tokenAddress == RibeUtils.getDaiAddress()) {
                share = shares[i].share;
                break;
            }
        }
    }

    function canInvest(address investor) public view returns (bool) {
        return investor == owner() || isPublic;
    }

}