// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "../lib/forge-std/src/Test.sol";
import {BasicNFT} from "../src/BasicNFT.sol";

contract BasicNFTTest is Test {
    BasicNFT private nft;
    address private constant USER = address(1);
    address private constant RECEIVER = address(2);

    function setUp() external {
        nft = new BasicNFT();
    }

    function testCollectionMetadataIsSet() external view {
        assertEq(nft.name(), "Simple IPFS Collection");
        assertEq(nft.symbol(), "SIPC");
        assertEq(nft.MAX_SUPPLY(), 3);
    }

    function testMintAssignsTokenAndIpfsUri() external {
        vm.prank(USER);
        uint256 tokenId = nft.mintNft();

        assertEq(tokenId, 0);
        assertEq(nft.ownerOf(tokenId), USER);
        assertEq(nft.balanceOf(USER), 1);
        assertEq(nft.tokenURI(tokenId), "ipfs://bafybeib6lq2j6x2w3q5l3h2r6n5k6x1v7m4z9q8p1r2s3t4u5v6w7x8y9a/1.json");
    }

    function testTransferWorksAfterApproval() external {
        vm.prank(USER);
        nft.mintNft();

        vm.prank(USER);
        nft.approve(address(this), 0);

        nft.transferFrom(USER, RECEIVER, 0);

        assertEq(nft.ownerOf(0), RECEIVER);
        assertEq(nft.balanceOf(USER), 0);
        assertEq(nft.balanceOf(RECEIVER), 1);
    }

    function testRevertsAfterMaxSupplyReached() external {
        for (uint256 i = 0; i < nft.MAX_SUPPLY(); i++) {
            nft.mintNft();
        }

        vm.expectRevert(BasicNFT.BasicNFT__MaxSupplyReached.selector);
        nft.mintNft();
    }
}
