pragma solidity ^0.4.24;


library CurveBabyJubJub {
    // Curve parameters
    // E: 168700x^2 + y^2 = 1 + 168696x^2y^2
    // A = 168700
    uint256 public constant A = 0x292FC;
    // D = 168696 
    uint256 public constant D = 0x292F8;
    // Prime Q = 21888242871839275222246405745257275088548364400416034343698204186575808495617
    uint256 public constant Q = 0x30644E72E131A029B85045B68181585D2833E84879B9709143E1F593F0000001;

    /**
     * @dev Add 2 points on baby jubjub curve
     * Formulae for adding 2 points on a twisted Edwards curve:
     * x3 = (x1y2 + y1x2) / (1 + dx1x2y1y2)
     * y3 = (y1y2 - ax1x2) / (1 - dx1x2y1y2)
     */
    function pointAdd(uint256 _x1, uint256 _y1, uint256 _x2, uint256 _y2) internal pure returns (uint256 x3, uint256 y3) {
        if (_x1 == 0 && _y1 == 0) {
            return (_x2, _y2);
        }

        if (_x2 == 0 && _y1 == 0) {
            return (_x1, _y1);
        }

        uint256 x1x2 = mulmod(_x1, _x2, Q);
        uint256 y1y2 = mulmod(_y1, _y2, Q);
        uint256 dx1x2y1y2 = mulmod(D, mulmod(x1x2, y1y2, Q), Q);
        uint256 x3Num = addmod(mulmod(_x1, _y2, Q), mulmod(_y1, _x2, Q), Q);
        uint256 y3Num = submod(y1y2, mulmod(A, x1x2, Q), Q);

        x3 = mulmod(x3Num, inverse(addmod(1, dx1x2y1y2, Q)), Q);
        y3 = mulmod(y3Num, inverse(submod(1, dx1x2y1y2, Q)), Q);
    }

    /**
     * @dev Double a point on baby jubjub curve
     * Doubling can be performed with the same formula as addition
     */
    function pointDouble(uint256 _x1, uint256 _y1) internal pure returns (uint256 x2, uint256 y2) {
        return pointAdd(_x1, _y1, _x1, _y1);
    }

    /**
     * @dev Multiply a point on baby jubjub curve by a scalar
     * Use the double and add algorithm
     */
    function pointMul(uint256 _x1, uint256 _y1, uint256 _d) internal pure returns (uint256 x2, uint256 y2) {
        uint256 remaining = _d;

        uint256 px = _x1;
        uint256 py = _y1;
        uint256 ax = 0;
        uint256 ay = 0;

        while (remaining != 0) {
            if ((remaining & 1) != 0) {
                // Binary digit is 1 so add
                (ax, ay) = pointAdd(ax, ay, px, py);
            }

            (px, py) = pointDouble(px, py);

            remaining = remaining / 2;
        }

        x2 = ax;
        y2 = ay;
    }

    /**
     * @dev Check if a given point is on the curve
     * (168700x^2 + y^2) - (1 + 168696x^2y^2) == 0
     */
    function isOnCurve(uint256 _x, uint256 _y) internal pure returns (bool) {
        uint256 xSq = mulmod(_x, _x, Q);
        uint256 ySq = mulmod(_y, _y, Q);
        uint256 lhs = addmod(mulmod(A, xSq, Q), ySq, Q);
        uint256 rhs = addmod(1, mulmod(mulmod(D, xSq, Q), ySq, Q), Q);
        return submod(lhs, rhs, Q) == 0;
    }

    /**
     * @dev Perform modular subtraction
     */
    function submod(uint256 _a, uint256 _b, uint256 _mod) internal pure returns (uint256) {
        uint256 aNN = _a;

        if (_a <= _b) {
            aNN += _mod;
        }

        return addmod(aNN - _b, 0, _mod);
    }

    /**
     * @dev Compute modular inverse of a number
     */
    function inverse(uint256 _a) internal pure returns (uint256) {
        uint256 t = 0;
        uint256 newT = 1;
        uint256 r = Q;
        uint256 newR = _a;
        uint256 left;

        while (newR != 0) {
            left = r / newR;

            (t, newT) = (newT, addmod(t, Q - mulmod(left, newT, Q), Q));
            (r, newR) = (newR, r - left * newR);
        }

        return t;
    }
}