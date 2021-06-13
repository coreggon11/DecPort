pragma solidity >=0.6.6;

import "./RibePortfolio.sol";

contract Ribe {

    mapping (address => RibePortfolio[]) private portfolios;
    uint private portfolioCount;

    constructor () public {

    }

    function createPortfolio(bool isPublic_, bool isDynamic_, address[] memory addresses_, uint16[] memory shares_) public {
        portfolios[msg.sender].push(new RibePortfolio(isPublic_, isDynamic_, addresses_, shares_));
        ++portfolioCount;
    }

    function getPortfolioCount() public view returns (uint) {
        return portfolioCount;
    }

}