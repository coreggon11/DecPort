pragma solidity ^0.8.0;

import "./RibePortfolio.sol";
import "./RibeUtils.sol";

contract RibeProtcol {

    using RibeUtils for uint16[];

    mapping (address => RibePortfolio[]) private portfolios;
    uint private portfolioCount;

    address private ribeUniswapUtilsAddress;

    constructor (address ribeUniswapUtilsAddress_) {
        ribeUniswapUtilsAddress = ribeUniswapUtilsAddress_;
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

    function investDai(address portfolioAddress) public {
        RibePortfolio portfolio = RibePortfolio(portfolioAddress);
        require(portfolio.canInvest(msg.sender), "Ribe Protcol: User can not invest in this portfolio!");
        // transfer usdt to weth
        // transfer weth to portfolio
    }

    function getPortfolioCount() public view returns (uint) {
        return portfolioCount;
    }

}