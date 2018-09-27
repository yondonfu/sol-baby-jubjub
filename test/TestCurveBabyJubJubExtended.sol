pragma solidity ^0.4.24;

import "../contracts/CurveBabyJubJubExtended.sol";
import "truffle/Assert.sol";


contract TestCurveBabyJubJubExtended {
    function test_pointAdd() public {
        uint256[2] memory p = [uint256(0), uint256(0)];
        uint256[4] memory etec = CurveBabyJubJubExtended.point2etec(p);
        uint256[4] memory resEtec = CurveBabyJubJubExtended.pointAdd(etec, etec);
        uint256[2] memory resPoint = CurveBabyJubJubExtended.etec2point(resEtec);
        Assert.equal(resPoint[0], 0, "should add (0, 0)");
        Assert.equal(resPoint[1], 0, "should add (0, 0)");

        p = [
            0x274DBCE8D15179969BC0D49FA725BDDF9DE555E0BA6A693C6ADB52FC9EE7A82C,
            0x5CE98C61B05F47FE2EAE9A542BD99F6B2E78246231640B54595FEBFD51EB853
        ];
        etec = CurveBabyJubJubExtended.point2etec(p);
        resEtec = CurveBabyJubJubExtended.pointAdd(etec, etec);
        resPoint = CurveBabyJubJubExtended.etec2point(resEtec);
        Assert.equal(resPoint[0], 0xF3C160E26FC96C347DD9E705EB5A3E8D661502728609FF95B3B889296901AB5, "should add self");
        Assert.equal(resPoint[1], 0x9979273078B5C735585107619130E62E315C5CAFE683A064F79DFED17EB14E1, "should add self");
    }

    function test_pointDouble() public {
        uint256[2] memory p = [
            0x274dbce8d15179969bc0d49fa725bddf9de555e0ba6a693c6adb52fc9ee7a82c,
            0x5ce98c61b05f47fe2eae9a542bd99f6b2e78246231640b54595febfd51eb853
        ];

        uint256[4] memory res = CurveBabyJubJubExtended.pointDouble(CurveBabyJubJubExtended.point2etec(p));
        uint256[2] memory resPoint = CurveBabyJubJubExtended.etec2point(res);
        Assert.equal(resPoint[0], 0xF3C160E26FC96C347DD9E705EB5A3E8D661502728609FF95B3B889296901AB5, "should double");
        Assert.equal(resPoint[1], 0x9979273078B5C735585107619130E62E315C5CAFE683A064F79DFED17EB14E1, "should double");
    }

    function test_pointDoubleDedicated() public {
        uint256[2] memory p = [
            0x274dbce8d15179969bc0d49fa725bddf9de555e0ba6a693c6adb52fc9ee7a82c,
            0x5ce98c61b05f47fe2eae9a542bd99f6b2e78246231640b54595febfd51eb853
        ];

        uint256[4] memory res = CurveBabyJubJubExtended.pointDoubleDedicated(CurveBabyJubJubExtended.point2etec(p));
        uint256[2] memory resPoint = CurveBabyJubJubExtended.etec2point(res);
        Assert.equal(resPoint[0], 0xF3C160E26FC96C347DD9E705EB5A3E8D661502728609FF95B3B889296901AB5, "should double");
        Assert.equal(resPoint[1], 0x9979273078B5C735585107619130E62E315C5CAFE683A064F79DFED17EB14E1, "should double");
    }

    function test_pointMul() public {
        uint256[2] memory p = [
            0x274DBCE8D15179969BC0D49FA725BDDF9DE555E0BA6A693C6ADB52FC9EE7A82C,
            0x5CE98C61B05F47FE2EAE9A542BD99F6B2E78246231640B54595FEBFD51EB853
        ];
        uint256[4] memory etec = CurveBabyJubJubExtended.point2etec(p);

        // 1 * (x1, y1)
        uint256 d = 1;
        uint256[4] memory resEtec = CurveBabyJubJubExtended.pointMul(etec, d);
        uint256[2] memory resPoint = CurveBabyJubJubExtended.etec2point(resEtec);
        Assert.equal(resPoint[0], 0x274DBCE8D15179969BC0D49FA725BDDF9DE555E0BA6A693C6ADB52FC9EE7A82C, "should multiply by 1");
        Assert.equal(resPoint[1], 0x5CE98C61B05F47FE2EAE9A542BD99F6B2E78246231640B54595FEBFD51EB853, "should multiply by 1");

        // 2 * (x1, y1)
        d = 2;
        resEtec = CurveBabyJubJubExtended.pointMul(etec, d);
        resPoint = CurveBabyJubJubExtended.etec2point(resEtec);
        Assert.equal(resPoint[0], 0xF3C160E26FC96C347DD9E705EB5A3E8D661502728609FF95B3B889296901AB5, "should multiply by 2");
        Assert.equal(resPoint[1], 0x9979273078B5C735585107619130E62E315C5CAFE683A064F79DFED17EB14E1, "should multiply by 2");

        // 7 * (x1, y1)
        d = 7;
        resEtec = CurveBabyJubJubExtended.pointMul(etec, d);
        resPoint = CurveBabyJubJubExtended.etec2point(resEtec);
        Assert.equal(resPoint[0], 0x5234237DB48A066A4E072C8A345DE7BB0F5A1D7230B6D62BDAA3E317E56A820, "should multiply by 7");
        Assert.equal(resPoint[1], 0x2B970CF66A6744AACFF7C68DAB8DE8BF9F49AE8A56BF78F60E992F65708A36A3, "should multiply by 7");

        // 15 * (x1, y1)
        d = 15;
        resEtec = CurveBabyJubJubExtended.pointMul(etec, d);
        resPoint = CurveBabyJubJubExtended.etec2point(resEtec);
        Assert.equal(resPoint[0], 0x14CC5477CD37C561309C318701C7B0A311FA5E8B7BCEB07849E5287037C20079, "should multiply by 15");
        Assert.equal(resPoint[1], 0xEFC81E2338DF9EEE05230F48F33D1A29FE9786A589D5889310ADC492D2C7870, "should multiply by 15");

        // 31 * (x1, y1)
        d = 31;
        resEtec = CurveBabyJubJubExtended.pointMul(etec, d);
        resPoint = CurveBabyJubJubExtended.etec2point(resEtec);
        Assert.equal(resPoint[0], 0x10DA60B985EF1F51DE59AA19A65E6EC7691ED298F51B5C5316862432EE1BFABC, "should multiply by 31");
        Assert.equal(resPoint[1], 0x444B1F4CE7B3DE187297A85E6E8D84FD3FBE929EAF90D5E6F22DCA4F4163B9, "should multiply by 31");

    }
}