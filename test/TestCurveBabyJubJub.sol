pragma solidity ^0.4.24;

import "../contracts/CurveBabyJubJub.sol";
import "truffle/Assert.sol";


contract TestCurveBabyJubJub {
    function test_isOnCurve() public {
        uint256 x1 = 0x274DBCE8D15179969BC0D49FA725BDDF9DE555E0BA6A693C6ADB52FC9EE7A82C;
        uint256 y1 = 0x5CE98C61B05F47FE2EAE9A542BD99F6B2E78246231640B54595FEBFD51EB853;
        Assert.isTrue(CurveBabyJubJub.isOnCurve(x1, y1), "point should be on curve");

        uint256 x2 = 0x2491ABA8D3A191A76E35BC47BD9AFE6CC88FEE14D607CBE779F2349047D5C157;
        uint256 y2 = 0x2E07297F8D3C3D7818DBDDFD24C35583F9A9D4ED0CB0C1D1348DD8F7F99152D7;
        Assert.isTrue(CurveBabyJubJub.isOnCurve(x2, y2), "point should be on curve");
    }

    function test_pointAdd() public {
        uint256 x1 = 0;
        uint256 y1 = 0;
        uint256 x2 = 0;
        uint256 y2 = 0;
        (uint256 x3, uint256 y3) = CurveBabyJubJub.pointAdd(x1, y1, x2, y2);
        Assert.equal(x3, 0, "should add (0, 0)");
        Assert.equal(y3, 0, "should add (0, 0)");

        x1 = 0x274DBCE8D15179969BC0D49FA725BDDF9DE555E0BA6A693C6ADB52FC9EE7A82C;
        y1 = 0x5CE98C61B05F47FE2EAE9A542BD99F6B2E78246231640B54595FEBFD51EB853;
        (x3, y3) = CurveBabyJubJub.pointAdd(x1, y1, 0, 1);
        Assert.equal(x3, 0x274DBCE8D15179969BC0D49FA725BDDF9DE555E0BA6A693C6ADB52FC9EE7A82C, "should add (0, 1)");
        Assert.equal(y3, 0x5CE98C61B05F47FE2EAE9A542BD99F6B2E78246231640B54595FEBFD51EB853, "should add (0, 1)");
        Assert.isTrue(CurveBabyJubJub.isOnCurve(x3, y3), "point should be on curve");

        (x3, y3) = CurveBabyJubJub.pointAdd(x1, y1, x1, y1);
        Assert.equal(x3, 0xF3C160E26FC96C347DD9E705EB5A3E8D661502728609FF95B3B889296901AB5, "should add self");
        Assert.equal(y3, 0x9979273078B5C735585107619130E62E315C5CAFE683A064F79DFED17EB14E1, "should add self");
        Assert.isTrue(CurveBabyJubJub.isOnCurve(x3, y3), "point should be on curve");
    }

    function test_pointDouble() public {
        uint256 x1 = 0x274DBCE8D15179969BC0D49FA725BDDF9DE555E0BA6A693C6ADB52FC9EE7A82C;
        uint256 y1 = 0x5CE98C61B05F47FE2EAE9A542BD99F6B2E78246231640B54595FEBFD51EB853;
        (uint256 x3, uint256 y3) = CurveBabyJubJub.pointDouble(x1, y1);
        Assert.equal(x3, 0xF3C160E26FC96C347DD9E705EB5A3E8D661502728609FF95B3B889296901AB5, "should double");
        Assert.equal(y3, 0x9979273078B5C735585107619130E62E315C5CAFE683A064F79DFED17EB14E1, "should double");
        Assert.isTrue(CurveBabyJubJub.isOnCurve(x3, y3), "point should be on curve");
    }

    function test_pointMul() public {
        uint256 x1 = 0x274DBCE8D15179969BC0D49FA725BDDF9DE555E0BA6A693C6ADB52FC9EE7A82C;
        uint256 y1 = 0x5CE98C61B05F47FE2EAE9A542BD99F6B2E78246231640B54595FEBFD51EB853;

        // 1 * (x1, y1)
        uint256 d = 1;
        (uint256 x2, uint256 y2) = CurveBabyJubJub.pointMul(x1, y1, d);
        Assert.equal(x2, 0x274DBCE8D15179969BC0D49FA725BDDF9DE555E0BA6A693C6ADB52FC9EE7A82C, "should multiply by 1");
        Assert.equal(y2, 0x5CE98C61B05F47FE2EAE9A542BD99F6B2E78246231640B54595FEBFD51EB853, "should multiply by 1");

        // 2 * (x1, y1)
        d = 2;
        (x2, y2) = CurveBabyJubJub.pointMul(x1, y1, d);
        Assert.equal(x2, 0xF3C160E26FC96C347DD9E705EB5A3E8D661502728609FF95B3B889296901AB5, "should multiply by 2");
        Assert.equal(y2, 0x9979273078B5C735585107619130E62E315C5CAFE683A064F79DFED17EB14E1, "should multiply by 2");

        // 7 * (x1, y1)
        d = 7;
        (x2, y2) = CurveBabyJubJub.pointMul(x1, y1, d);
        Assert.equal(x2, 0x5234237DB48A066A4E072C8A345DE7BB0F5A1D7230B6D62BDAA3E317E56A820, "should multiply by 7");
        Assert.equal(y2, 0x2B970CF66A6744AACFF7C68DAB8DE8BF9F49AE8A56BF78F60E992F65708A36A3, "should multiply by 7");

        // 15 * (x1, y1)
        d = 15;
        (x2, y2) = CurveBabyJubJub.pointMul(x1, y1, d);
        Assert.equal(x2, 0x14CC5477CD37C561309C318701C7B0A311FA5E8B7BCEB07849E5287037C20079, "should multiply by 15");
        Assert.equal(y2, 0xEFC81E2338DF9EEE05230F48F33D1A29FE9786A589D5889310ADC492D2C7870, "should multiply by 15");

        // 31 * (x1, y1)
        d = 31;
        (x2, y2) = CurveBabyJubJub.pointMul(x1, y1, d);
        Assert.equal(x2, 0x10DA60B985EF1F51DE59AA19A65E6EC7691ED298F51B5C5316862432EE1BFABC, "should multiply by 31");
        Assert.equal(y2, 0x444B1F4CE7B3DE187297A85E6E8D84FD3FBE929EAF90D5E6F22DCA4F4163B9, "should multiply by 31");
    }
}