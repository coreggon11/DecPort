pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./RibeUtils.sol";

contract RibeShareToken is ERC20, Ownable {

    using RibeUtils for uint;

    address public portfolioOwner;

    // owner is the portfolio
    constructor(string memory portfolioName, address portfolioOwner_) ERC20(portfolioName, "RST") Ownable() {
       portfolioOwner = portfolioOwner_;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function invest(address investor, uint daiInvested, uint daiPortfolioPrice) public onlyOwner() {
        require(daiInvested > 0, "Ribe Protocol: 0 DAI invested");
        uint tokensMinted = totalSupply() == 0 ? daiInvested.div(10 ** decimals()) : daiInvested.div(daiPortfolioPrice.div(totalSupply()));
        // how many tokens there are
        if(investor == portfolioOwner) {
            _mint(investor, tokensMinted);
        } else {
            // if investor is not portfolio owner we pay 0.5% to portfolio owner
            uint ownerFee = tokensMinted.percent(50);
            _mint(portfolioOwner, ownerFee);
            _mint(investor, tokensMinted.sub(ownerFee));
        }
    }

}