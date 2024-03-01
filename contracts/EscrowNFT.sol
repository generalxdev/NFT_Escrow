// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract EscrowNFT is ERC721Burnable, ERC721Enumerable, Ownable {
    uint256 public tokenCounter = 0;

    // NFT data
    mapping(uint256 => uint256) public amount;
    mapping(uint256 => uint256) public matureTime;

    constructor() ERC721("EscrowNFT", "ESCRW") {
    }

    function mint(address _recipient, uint256 _amount, uint256 _matureTime) public onlyOwner returns (uint256) {
        _mint(_recipient, tokenCounter);

        // set values
        amount[tokenCounter] = _amount;
        matureTime[tokenCounter] = _matureTime;

        // increment counter
        tokenCounter++;

        return tokenCounter - 1; // return ID
    }

    function tokenDetails(uint256 _tokenId) public view returns (uint256, uint256) {
        require(_exists(_tokenId), "EscrowNFT: Query for nonexistent token");

        return (amount[_tokenId], matureTime[_tokenId]);
    }

     function contractAddress() public view returns (address) {
        return address(this);
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 firstTokenId, uint256 batchSize) internal override(ERC721, ERC721Enumerable) {}

    function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) { }
}
