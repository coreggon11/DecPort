pragma solidity >=0.8.0;

library RibeUtils {

    function uint16ArraySum(uint16[] memory array) external pure returns (uint) {
        uint output = 0;
        for(uint i = 0; i < array.length; ++i){
            output += array[i];
        }
        return output;
    }

    // max of two numbers
    function max(uint a, uint b) external pure returns (uint) {
        return a > b ? a : b;
    }

    // overflow safe subtraction
    function sub(uint a, uint b) external pure returns (uint) {
        require(a > b, "Math Error: Overflow");
        return a - b;
    }

    // overflow safe addition
    function add(uint a, uint b) external pure returns (uint) {
        uint out = a + b;
        require((out > a && out > b) || (a == 0) || (b == 0), "Math Error: Overflow");
        return out;
    }

    // overflow safe multiplication
    function mul(uint a, uint b) external pure returns (uint) {
        if(a == 0 || b == 0) {
            return 0;
        }
        uint out = a * b;
        require(out / b == a, "Math Error: Overflow");
        return out;
    }

    // zero safe division
    function div(uint a, uint b) external pure returns (uint) {
        require(b != 0, "Math Error: Dividing by zero");
        return a / b;
    }

    /*
    returns how much is 'b' percent of 'a'
    Ribe uses 2 floating points for percentages, so 100% = 10 000 so we can get e.g 0.01%  
     */
    function percent(uint a, uint b) external pure returns (uint) {
        if(a == 0 || b == 0) {
            return 0;
        }
        uint first = a * b;
        require(first / b == a, "Math Error: Overflow");
        return first / 10000;
    }

}