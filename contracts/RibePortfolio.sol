pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RibePortfolio is Ownable {

    bool private isPublic;
    bool private isDynamic;
    Share[] private shares;
    mapping(address => uint) tokenCounts;

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

    function canInvest(address investor) public view returns (bool) {
        return investor == owner() || isPublic;
    }

}