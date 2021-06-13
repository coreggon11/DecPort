pragma solidity >=0.6.6;

import "./RibePortfolio.sol";
import "./RibeUtils.sol";

contract Ribe {

    using RibeUtils for uint16[];

    mapping (address => RibePortfolio[]) private portfolios;
    uint private portfolioCount;

    constructor () public {

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

    function investUsdt(address portfolio) public {
        // what portfolio? portfolio
        // who? msg.sender
        // transfer usdt to weth
        //
    }

    function getPortfolioCount() public view returns (uint) {
        return portfolioCount;
    }

}