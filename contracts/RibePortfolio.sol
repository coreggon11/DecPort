pragma solidity >=0.8.0;

contract RibePortfolio {

    bool private isPublic;
    bool private isDynamic;
    Share[] private shares;
    mapping(address => uint) tokenCounts;

    struct Share {
        address tokenAddress;   // address of the token
        uint16 share;           // share of the token in %
    }

    constructor (bool isPublic_, bool isDynamic_, address[] memory addresses_, uint16[] memory shares_) public {
        isPublic = isPublic_;
        isDynamic = isDynamic_;
        for(uint i = 0; i < addresses_.length; ++i) {
            shares.push(Share(addresses_[i], shares_[i]));
        }
    }

}