// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC165} from "../lib/forge-std/src/interfaces/IERC165.sol";
import {IERC721, IERC721Metadata, IERC721TokenReceiver} from "../lib/forge-std/src/interfaces/IERC721.sol";

contract BasicNFT is IERC721Metadata {
    error BasicNFT__ZeroAddress();
    error BasicNFT__TokenDoesNotExist();
    error BasicNFT__NotAuthorized();
    error BasicNFT__InvalidOwner();
    error BasicNFT__UnsafeRecipient();
    error BasicNFT__MaxSupplyReached();

    string private constant COLLECTION_NAME = "Simple IPFS Collection";
    string private constant COLLECTION_SYMBOL = "SIPC";
    uint256 public constant MAX_SUPPLY = 3;

    string[MAX_SUPPLY] private s_ipfsTokenUris = [
        "ipfs://bafybeib6lq2j6x2w3q5l3h2r6n5k6x1v7m4z9q8p1r2s3t4u5v6w7x8y9a/1.json",
        "ipfs://bafybeib6lq2j6x2w3q5l3h2r6n5k6x1v7m4z9q8p1r2s3t4u5v6w7x8y9a/2.json",
        "ipfs://bafybeib6lq2j6x2w3q5l3h2r6n5k6x1v7m4z9q8p1r2s3t4u5v6w7x8y9a/3.json"
    ];

    uint256 private s_nextTokenId;
    mapping(uint256 tokenId => address owner) private s_ownerOf;
    mapping(address owner => uint256 balance) private s_balanceOf;
    mapping(uint256 tokenId => address approved) private s_tokenApprovals;
    mapping(address owner => mapping(address operator => bool approved)) private s_operatorApprovals;

    function name() external pure returns (string memory) {
        return COLLECTION_NAME;
    }

    function symbol() external pure returns (string memory) {
        return COLLECTION_SYMBOL;
    }

    function totalMinted() external view returns (uint256) {
        return s_nextTokenId;
    }

    function mintNft() external returns (uint256 tokenId) {
        if (s_nextTokenId >= MAX_SUPPLY) {
            revert BasicNFT__MaxSupplyReached();
        }

        tokenId = s_nextTokenId;
        unchecked {
            s_nextTokenId++;
            s_balanceOf[msg.sender]++;
        }
        s_ownerOf[tokenId] = msg.sender;

        emit Transfer(address(0), msg.sender, tokenId);
    }

    function balanceOf(address owner) external view returns (uint256) {
        if (owner == address(0)) {
            revert BasicNFT__InvalidOwner();
        }
        return s_balanceOf[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = s_ownerOf[tokenId];
        if (owner == address(0)) {
            revert BasicNFT__TokenDoesNotExist();
        }
        return owner;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        ownerOf(tokenId);
        return s_ipfsTokenUris[tokenId];
    }

    function approve(address approved, uint256 tokenId) external payable {
        address owner = ownerOf(tokenId);
        if (msg.sender != owner && !s_operatorApprovals[owner][msg.sender]) {
            revert BasicNFT__NotAuthorized();
        }

        s_tokenApprovals[tokenId] = approved;
        emit Approval(owner, approved, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) external {
        s_operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        ownerOf(tokenId);
        return s_tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return s_operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public payable {
        address owner = ownerOf(tokenId);
        if (owner != from) {
            revert BasicNFT__NotAuthorized();
        }
        if (to == address(0)) {
            revert BasicNFT__ZeroAddress();
        }
        if (!_isApprovedOrOwner(msg.sender, tokenId, owner)) {
            revert BasicNFT__NotAuthorized();
        }

        delete s_tokenApprovals[tokenId];
        unchecked {
            s_balanceOf[from]--;
            s_balanceOf[to]++;
        }
        s_ownerOf[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external payable {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public payable {
        transferFrom(from, to, tokenId);
        if (!_checkOnERC721Received(from, to, tokenId, data)) {
            revert BasicNFT__UnsafeRecipient();
        }
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IERC165).interfaceId || interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId;
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId, address owner) private view returns (bool) {
        return spender == owner || s_tokenApprovals[tokenId] == spender || s_operatorApprovals[owner][spender];
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data)
        private
        returns (bool)
    {
        if (to.code.length == 0) {
            return true;
        }

        try IERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
            return retval == IERC721TokenReceiver.onERC721Received.selector;
        } catch {
            return false;
        }
    }
}
