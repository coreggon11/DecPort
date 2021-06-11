pragma solidity >=0.6.6;

library PortfolioUtils {

    struct Share {
        address tokenAddress; // address of the token
        uint16 share;           // share of the token in %
    }

}