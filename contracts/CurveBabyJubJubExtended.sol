pragma solidity ^0.4.24;


/**
 * @dev Baby jubjub curve using extended twisted edwards coordinate points
 * Paper on extended twisted edwards coordinates: https://www.iacr.org/archive/asiacrypt2008/53500329/53500329.pdf
 * Based on Python implementation: https://github.com/HarryR/ethsnarks/blob/jubjub/ethsnarks/jubjub.py 
 */
library CurveBabyJubJubExtended {
    // Curve parameters
    // E: 168700x^2 + y^2 = 1 + 168696x^2y^2
    // A = 168700
    uint256 public constant A = 0x292FC;
    // D = 168696 
    uint256 public constant D = 0x292F8;
    // Prime Q = 21888242871839275222246405745257275088548364400416034343698204186575808495617
    uint256 public constant Q = 0x30644E72E131A029B85045B68181585D2833E84879B9709143E1F593F0000001;

    /**
     * @dev Add 2 etec points on baby jubjub curve
     * x3 = (x1y2 + y1x2) * (z1z2 - dt1t2)
     * y3 = (y1y2 - ax1x2) * (z1z2 + dt1t2)
     * t3 = (y1y2 - ax1x2) * (x1y2 + y1x2)
     * z3 = (z1z2 - dt1t2) * (z1z2 + dt1t2)
     */
    function pointAdd(uint256[4] _p1, uint256[4] _p2) internal view returns (uint256[4] p3) {
        if (_p1[0] == 0 && _p1[1] == 0 && _p1[2] == 0 && _p1[3] == 0) {
            return _p2;
        }

        if (_p2[0] == 0 && _p2[1] == 0 && _p2[2] == 0 && _p2[3] == 0) {
            return _p1;
        }

        uint256[8] memory intermediates;
        // A <- x1 * x2
        intermediates[0] = mulmod(_p1[0], _p2[0], Q);
        // B <- y1 * y2
        intermediates[1] = mulmod(_p1[1], _p2[1], Q);
        // C <- d * t1 * t2
        intermediates[2] = mulmod(mulmod(D, _p1[2], Q), _p2[2], Q);
        // D <- z1 * x2
        intermediates[3] = mulmod(_p1[3], _p2[3], Q);
        // E <- (x1 + y1) * (x2 + y2) - A - B
        intermediates[4] = submod(submod(mulmod(addmod(_p1[0], _p1[1], Q), addmod(_p2[0], _p2[1], Q), Q), intermediates[0], Q), intermediates[1], Q);
        // F <- D - C
        intermediates[5] = submod(intermediates[3], intermediates[2], Q);
        // G <- D + C
        intermediates[6] = addmod(intermediates[3], intermediates[2], Q);
        // H <- B - a * A
        intermediates[7] = submod(intermediates[1], mulmod(A, intermediates[0], Q), Q);

        // x3
        p3[0] = mulmod(intermediates[4], intermediates[5], Q);
        // y3
        p3[1] = mulmod(intermediates[6], intermediates[7], Q);
        // t3
        p3[2] = mulmod(intermediates[4], intermediates[7], Q);
        // z3
        p3[3] = mulmod(intermediates[5], intermediates[6], Q);
    }

    /**
     * @dev Double a etec point on baby jubjub curve
     * Doubling can be performed with the same formula as addition
     */
    function pointDouble(uint256[4] _p) internal view returns (uint256[4] p2) {
        p2 = pointAdd(_p, _p);
    }

    /**
     * @dev Double a etec point using dedicated double algorithm
     */
    function pointDoubleDedicated(uint256[4] _p) internal view returns (uint256[4] p2) {
        uint256[8] memory intermediates;
        // A <- x1 * x1
        intermediates[0] = mulmod(_p[0], _p[0], Q);
        // B <- y1 * y1
        intermediates[1] = mulmod(_p[1], _p[1], Q);
        // C <- 2 * z1 * z1
        intermediates[2] = mulmod(mulmod(2, _p[3], Q), _p[3], Q);
        // D <- a * A
        intermediates[3] = mulmod(A, intermediates[0], Q);
        // E <- (x1 + y1)^2 - A - B
        intermediates[4] = submod(submod(expmod(addmod(_p[0], _p[1], Q), 2, Q), intermediates[0], Q), intermediates[1], Q);
        // G <- D + B
        intermediates[5] = addmod(intermediates[3], intermediates[1], Q);
        // F <- G - C
        intermediates[6] = submod(intermediates[5], intermediates[2], Q);
        // H <- D - B
        intermediates[7] = submod(intermediates[3], intermediates[1], Q);

        // x3 <- E * F
        p2[0] = mulmod(intermediates[4], intermediates[6], Q);
        // y3 <- G * H
        p2[1] = mulmod(intermediates[5], intermediates[7], Q);
        // t3 <- E * H
        p2[2] = mulmod(intermediates[4], intermediates[7], Q);
        // z3 <- F * G
        p2[3] = mulmod(intermediates[6], intermediates[5], Q);
    }

    /**
     * @dev Multiply a etec point on baby jubjub curve by a scalar
     * Use the double and add algorithm
     */
    function pointMul(uint256[4] _p, uint256 _d) internal view returns (uint256[4] p) {
        uint256 remaining = _d;

        uint256[4] memory pp = _p;
        uint256[4] memory ap = [uint256(0), uint256(0), uint256(0), uint256(0)];

        while (remaining != 0) {
            if ((remaining & 1) != 0) {
                // Binary digit is 1 so add
                ap = pointAdd(ap, pp);
            }

            pp = pointDouble(pp);

            remaining = remaining / 2;
        }

        p = ap;
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
    function inverse(uint256 _a) internal view returns (uint256) {
        // We can use Euler's theorem instead of the extended Euclidean algorithm
        // Since m = Q and Q is prime we have: a^-1 = a^(m - 2) (mod m)
        return expmod(_a, Q - 2, Q);
    }

    /**
     * @dev Helper function to call the bigModExp precompile
     */
    function expmod(uint256 _b, uint256 _e, uint256 _m) internal view returns (uint256 o) {
        assembly {
            let memPtr := mload(0x40)
            mstore(memPtr, 0x20) // Length of base _b
            mstore(add(memPtr, 0x20), 0x20) // Length of exponent _e
            mstore(add(memPtr, 0x40), 0x20) // Length of modulus _m
            mstore(add(memPtr, 0x60), _b) // Base _b
            mstore(add(memPtr, 0x80), _e) // Exponent _e
            mstore(add(memPtr, 0xa0), _m) // Modulus _m

            // The bigModExp precompile is at 0x05
            let success := call(gas, 0x05, 0x0, memPtr, 0xc0, memPtr, 0x20)
            switch success
            case 0 {
                revert(0x0, 0x0)
            } default {
                o := mload(memPtr)
            }
        }
    }

    /**
     * @dev Convert etec point to affine point
     */
    function etec2point(uint256[4] _etec) internal view returns (uint256[2] p) {
        uint256 invZ = inverse(_etec[3]);
        p[0] = mulmod(_etec[0], invZ, Q);
        p[1] = mulmod(_etec[1], invZ, Q);
    }

    /**
     * @dev Convert affine point to etec point
     */
    function point2etec(uint256[2] _p) internal pure returns (uint256[4] etec) {
        etec[0] = _p[0];
        etec[1] = _p[1];
        etec[2] = mulmod(_p[0], _p[1], Q);
        etec[3] = 1;
    }
}
