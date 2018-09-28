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
    function pointAdd(uint256[4] _p1, uint256[4] _p2) internal pure returns (uint256[4] p3) {
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
     * @dev Add 2 etec points on baby jubjub curve
     * x3 = (x1y2 + y1x2) * (z1z2 - dt1t2)
     * y3 = (y1y2 - ax1x2) * (z1z2 + dt1t2)
     * t3 = (y1y2 - ax1x2) * (x1y2 + y1x2)
     * z3 = (z1z2 - dt1t2) * (z1z2 + dt1t2)
     */
    function pointAddASM(
        uint256[4] _p1,
        uint256[4] _p2
    ) 
        internal
        pure
        returns (uint256[4] p3)
    {
        if (_p1[0] == 0 && _p1[1] == 0 && _p1[2] == 0 && _p1[3] == 0) {
            return _p2;
        }

        if (_p2[0] == 0 && _p2[1] == 0 && _p2[2] == 0 && _p2[3] == 0) {
            return _p1;
        }

        assembly {
            let localQ := 0x30644E72E131A029B85045B68181585D2833E84879B9709143E1F593F0000001 
            let localA := 0x292FC
            let localD := 0x292F8 

            // A <- x1 * x2
            let a := mulmod(mload(_p1), mload(_p2), localQ)
            // B <- y1 * y2
            let b := mulmod(mload(add(_p1, 0x20)), mload(add(_p2, 0x20)), localQ)
            // C <- d * t1 * t2
            let c := mulmod(mulmod(localD, mload(add(_p1, 0x40)), localQ), mload(add(_p2, 0x40)), localQ)
            // D <- z1 * z2
            let d := mulmod(mload(add(_p1, 0x60)), mload(add(_p2, 0x60)), localQ)
            // E <- (x1 + y1) * (x2 + y2) - A - B
            let e := mulmod(addmod(mload(_p1), mload(add(_p1, 0x20)), localQ), addmod(mload(_p2), mload(add(_p2, 0x20)), localQ), localQ)
            if lt(e, add(a, 1)) {
                e := add(e, localQ)
            }
            e := mod(sub(e, a), localQ)
            if lt(e, add(b, 1)) {
                e := add(e, localQ)
            }
            e := mod(sub(e, b), localQ)
            // F <- D - C
            let f := d
            if lt(f, add(c, 1)) {
                f := add(f, localQ)
            }
            f := mod(sub(f, c), localQ)
            // G <- D + C
            let g := addmod(d, c, localQ)
            // H <- B - a * A
            let aA := mulmod(localA, a, localQ)
            let h := b
            if lt(h, add(aA, 1)) {
                h := add(h, localQ)
            }
            h := mod(sub(h, aA), localQ)

            // x3 <- E * F
            mstore(p3, mulmod(e, f, localQ))
            // y3 <- G * H
            mstore(add(p3, 0x20), mulmod(g, h, localQ))
            // t3 <- E * H
            mstore(add(p3, 0x40), mulmod(e, h, localQ))
            // z3 <- F * G
            mstore(add(p3, 0x60), mulmod(f, g, localQ))
        }
    }

    /**
     * @dev Double a etec point on baby jubjub curve
     * Doubling can be performed with the same formula as addition
     */
    function pointDouble(uint256[4] _p) internal pure returns (uint256[4] p2) {
        p2 = pointAdd(_p, _p);
    }

    /**
     * @dev Double a etec point on baby jubjub curve
     * Doubling can be performed with the same formula as addition
     */
    function pointDoubleASM(uint256[4] _p) internal pure returns (uint256[4] p2) {
        p2 = pointAddASM(_p, _p);
    }

    /**
     * @dev Double a etec point using dedicated double algorithm
     */
    function pointDoubleDedicated(uint256[4] _p) internal pure returns (uint256[4] p2) {
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
        uint256 x1_plus_y1 = addmod(_p[0], _p[1], Q);
        intermediates[4] = submod(submod(mulmod(x1_plus_y1, x1_plus_y1, Q), intermediates[0], Q), intermediates[1], Q);
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
     * @dev Double a etec point using dedicated double algorithm
     */
    function pointDoubleDedicatedASM(
        uint256 _x, 
        uint256 _y,
        uint256 _t,
        uint256 _z
    ) 
        internal 
        pure
        returns (uint256 x, uint256 y, uint256 t, uint256 z)
    {
        assembly {
            let localQ := 0x30644E72E131A029B85045B68181585D2833E84879B9709143E1F593F0000001 
            let localA := 0x292FC

            // A <- x1 * x1
            let a := mulmod(_x, _x, localQ)
            // B <- y1 * y1
            let b := mulmod(_y, _y, localQ)
            // C <- 2 * z1 * z1
            let c := mulmod(mulmod(2, _z, localQ), _z, localQ)
            // D <- a * A
            let d := mulmod(localA, a, localQ)
            // E <- (x1 + y1)^2 - A - B
            let e := addmod(_x, _y, localQ)
            e := mulmod(e, e, localQ)
            if lt(e, add(a, 1)) {
                e := add(e, localQ)
            }
            e := mod(sub(e, a), localQ)
            if lt(e, add(b, 1)) {
                e := add(e, localQ)
            }
            e := mod(sub(e, b), localQ)
            // G <- D + B
            let g := addmod(d, b, localQ)
            // F <- G - C
            let f := g
            if lt(f, add(c, 1)) {
                f := add(f, localQ)
            }
            f := mod(sub(f, c), localQ)
            // H <- D - B
            let h := d
            if lt(h, add(b, 1)) {
                h := add(h, localQ)
            }
            h := mod(sub(h, b), localQ)

            // x3 <- E * F
            x := mulmod(e, f, localQ)
            // y3 <- G * H
            y := mulmod(g, h, localQ)
            // t3 <- E * H
            t := mulmod(e, h, localQ)
            // z3 <- F * G
            z := mulmod(f, g, localQ)
        }
    }

    /**
     * @dev Multiply a etec point on baby jubjub curve by a scalar
     * Use the double and add algorithm
     */
    function pointMul(uint256[4] _p, uint256 _d) internal pure returns (uint256[4] p) {
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
            let success := staticcall(gas, 0x05, memPtr, 0xc0, memPtr, 0x20)
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
