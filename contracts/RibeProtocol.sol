pragma solidity ^0.8.0;

import "./RibePortfolio.sol";

contract RibeProtcol {

    using RibeUtils for uint16[];
    using RibeUtils for uint;

    mapping (address => RibePortfolio[]) private portfolios;
    uint private portfolioCount;

    address public devAddress;
    
    uint public daiFees;

    constructor () {
        devAddress = msg.sender;        
    }

    function createPortfolio(bool isPublic_, bool isDynamic_, address[] memory addresses_, uint16[] memory shares_) public {
        require(shares_.length == addresses_.length, "Ribe Protocol : Number of tokens does not match number of shares!");
        require(shares_.uint16ArraySum() == 10000, "Ribe Protocol : Total shares must be 100%!");
        portfolios[msg.sender].push(new RibePortfolio(isPublic_, isDynamic_, addresses_, shares_));
        ++portfolioCount;
    }

    function getUserPortfolios(address user) public view returns (RibePortfolio[] memory) {
        return portfolios[user];
    }
    
    /*
    since we do not want users to pay gas for sending fees we leave it on dev (or anyone) to collect them personally
     */
    function collectFees() public {
        IERC20 dai = IERC20(RibeUtils.getDaiAddress());
        uint amountDai = daiFees;
        if(dai.balanceOf(address(this)) > daiFees) {
            // if there is more in the contract than expected 
            // it will be used to buyback ribe tokens from uniswap and burn them
            uint daiLeft = dai.balanceOf(address(this)).sub(daiFees);
            // TODO buy back ribe token from uniswap
            // TODO burn bought ribe
        } else {
            // if there is more fees expected than actual balance, we adjust
            amountDai = dai.balanceOf(address(this));
        }
        // IERC20 dai = IERC20(RibeUtils.getDaiAddress());
        //dai.approve(devAddress_, dai.totalSupply());
        // TODO approve ribe token/
        dai.transfer(devAddress, amountDai);
        daiFees = 0;
    }

    function investDai(address portfolioAddress, uint amountDai, uint deadline) public {
        RibePortfolio portfolio = RibePortfolio(portfolioAddress);
        require(portfolio.canInvest(msg.sender), "Ribe Protcol: User can not invest in this portfolio!");
        IERC20 dai = IERC20(RibeUtils.getDaiAddress());
        IERC20 weth = IERC20(RibeUtils.getWethAddress());
        // user needs allowance
        require(dai.allowance(msg.sender, address(this)) >= amountDai, "Ribe Protocol: Not allowed to spend user's DAI");
        // first we send dai from user to ribe
        require(dai.transferFrom(msg.sender, address(this), amountDai), "Ribe Protocol: Failed to transfer user's DAI");
        // 1 % goes to dev
        uint devFee = amountDai.percent(100);
        // amount dai we work with since now
        uint taxedDaiAmount = amountDai.sub(devFee);
        uint daiSwapAmount = taxedDaiAmount.sub(portfolio.amountDaiInPortfolio(taxedDaiAmount, RibeUtils.getDaiAddress()));
        // since we use uniswap for the buys and sells and most pairs on uniswap are against weth we convert dai to weth and
        // try to buy tokens in weth
        // approve dai
        dai.approve(RibeUtils.getRouterAddress(), daiSwapAmount);
        // swap dai to weth
        uint wethBefore =  weth.balanceOf(portfolioAddress);
        IUniswapV2Router01(RibeUtils.getRouterAddress())
            .swapExactTokensForTokens(daiSwapAmount, 
                RibeUtils.getMinEthForDaiWithSlippage(daiSwapAmount), 
                RibeUtils.getDaiWethPath(), 
                portfolioAddress, 
                deadline);
        uint wethTransferred = weth.balanceOf(portfolioAddress).sub(wethBefore);
        // transfer dai left to portfolio
        dai.transfer(portfolioAddress, taxedDaiAmount.sub(daiSwapAmount));
        // now call invest over portfolio
        if(portfolio.daiShare() == 0) {
            // if no dai is in portfolio then invest weth
            portfolio.investWeth(msg.sender, wethTransferred);
        } else {
            portfolio.investDai(msg.sender, taxedDaiAmount, wethTransferred);
        }
    }

    function getPortfolioCount() public view returns (uint) {
        return portfolioCount;
    }

}