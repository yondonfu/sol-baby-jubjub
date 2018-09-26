pragma solidity ^0.4.24;

import "./CurveBabyJubJub.sol";


contract CurveBabyJubJubHelper {
    function pointAdd(uint256 _x1, uint256 _y1, uint256 _x2, uint256 _y2) public view returns (uint256 x3, uint256 y3) {
        (x3, y3) = CurveBabyJubJub.pointAdd(_x1, _y1, _x2, _y2);
    }

    function pointMul(uint256 _x1, uint256 _y1, uint256 _d) public view returns (uint256 x2, uint256 y2) {
        (x2, y2) = CurveBabyJubJub.pointMul(_x1, _y1, _d);
    }

    function pointDouble(uint256 _x1, uint256 _y1) public view returns (uint256 x2, uint256 y2) {
        (x2, y2) = CurveBabyJubJub.pointDouble(_x1, _y1);
    }
}