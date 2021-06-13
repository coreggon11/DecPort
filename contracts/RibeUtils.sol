pragma solidity >=0.8.0;

library RibeUtils {

    function uint16ArraySum(uint16[] memory array) public pure returns (uint) {
        uint output = 0;
        for(uint i = 0; i < array.length; ++i){
            output += array[i];
        }
        return output;
    }

}