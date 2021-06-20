pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";

import "./RibeShareToken.sol";

contract RibePortfolio is Ownable {

    using RibeUtils for uint;

    bool private isPublic;
    bool private isDynamic;
    Share[] private shares;
    string public portfolioName;

    address public portfolioTokenAddress;

    modifier allowedInvestor(address investor) {
        require(canInvest(investor), "Ribe Protocol: User can not invest in this portfolio!");
        _;
    }

    struct Share {
        address tokenAddress;   // address of the token
        uint16 share;           // share of the token in %
    }

    constructor (address owner, string memory portfolioName_, bool isPublic_, bool isDynamic_, address[] memory addresses_, uint16[] memory shares_) Ownable() public {
        portfolioName = portfolioName_;
        isPublic = isPublic_;
        isDynamic = isDynamic_;
        for(uint i = 0; i < addresses_.length; ++i) {
            shares.push(Share(addresses_[i], shares_[i]));
        }
        // create tokne
        RibeShareToken rst = new RibeShareToken(portfolioName, owner);
        portfolioTokenAddress = address(rst);
    }

    function investDai(address investor, uint amountDai, uint wethTransferred, uint deadline)
        external allowedInvestor(investor) {
        if(isDynamic) {
            investDaiDynamic(investor, amountDai, wethTransferred, deadline);
        } else {
            investDaiStatic(investor, amountDai, wethTransferred, deadline);
        }
    }

    function investWeth(address investor, uint amountDai, uint wethTransferred, uint deadline) 
        external allowedInvestor(investor) {
        if(isDynamic) {
            investWethDynamic(investor, amountDai, wethTransferred, deadline);
        } else {
            investWethStatic(investor, amountDai, wethTransferred, deadline);
        }
    }

    function investDaiStatic(address investor, uint amountDai, uint wethTransferred, uint deadline) private {
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
            // how much token do I get for weth
            // swap dai to weth
            IUniswapV2Router01(RibeUtils.getRouterAddress())
                .swapExactTokensForTokens(wethToSwap, 
                    RibeUtils.getMinTokenForEthWithSlippage(wethToSwap, shares[i].tokenAddress), 
                    RibeUtils.getWethTokenPath(shares[i].tokenAddress), 
                    address(this), 
                    deadline);
        }
        RibeShareToken(portfolioTokenAddress).invest(investor, amountDai, getPortfolioDaiPrice());
    }

    function investDaiDynamic(address investor, uint amountDai, uint wethTransferred, uint deadline) private {
        // TODO
    }

    function investWethStatic(address investor, uint amountDai, uint wethTransferred, uint deadline) private {
       // TODO
    }

    function investWethDynamic(address investor, uint amountDai, uint wethTransferred, uint deadline) private {
       // TODO
    }

    function getPortfolioDaiPrice() public view returns (uint) {
        uint out = 0;
        uint amountWeth = 0;
        for(uint i; i < shares.length; ++i) {
            IERC20 token = IERC20(shares[i].tokenAddress);
            if(shares[i].tokenAddress == RibeUtils.getDaiAddress()) {
                // if dai just add
                out += token.balanceOf(address(this));
                continue;
            }
            if(shares[i].tokenAddress == RibeUtils.getWethAddress()) {
                amountWeth += token.balanceOf(address(this));
            } else {
                // how much weth do i get for this token
                amountWeth += RibeUtils.tokenPriceEther(shares[i].tokenAddress, token.balanceOf(address(this)));
            }
        }
        // how much dai do i get for weth
        out += RibeUtils.etherPriceDai(amountWeth);
        return out;
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