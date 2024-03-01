// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./EscrowNFT.sol";

contract Escrow is Ownable {

    EscrowNFT public escrowNFT;
    bool public initialized = false;

    event Escrowed(address _from, address _to, uint256 _amount, uint256 _matureTime);
    event Redeemed(address _recipient, uint256 _amount);
    event Initialized(address _escrowNft);

    modifier isInitialized() {
        require(initialized, "Contract is not yet initialized");
        _;
    }

    function initialize(address _escrowNftAddress) external onlyOwner {
        require(!initialized, "Contract already initialized.");
        escrowNFT = EscrowNFT(_escrowNftAddress);
        initialized = true;

        emit Initialized(_escrowNftAddress);
    }

     function escrowEth(address _recipient, uint256 _duration) external payable isInitialized {
        require(_recipient != address(0), "Cannot escrow to zero address.");
        require(msg.value > 0, "Cannot escrow 0 ETH.");

        uint256 amount = msg.value;
        uint256 matureTime = block.timestamp + _duration;

        escrowNFT.mint(_recipient, amount, matureTime);

        emit Escrowed(msg.sender,
            _recipient,
            amount,
            matureTime);
    }

    function redeemEthFromEscrow(uint256 _tokenId) external isInitialized {
        require(escrowNFT.ownerOf(_tokenId) == msg.sender, "Must own token to claim underlying Eth");

        (uint256 amount, uint256 matureTime) = escrowNFT.tokenDetails(_tokenId);
        require(matureTime <= block.timestamp, "Escrow period not expired.");

        escrowNFT.burn(_tokenId);

        (bool success, ) = msg.sender.call{value: amount}("");

        require(success, "Transfer failed.");

        emit Redeemed(msg.sender, amount);
    }

    function redeemAllAvailableEth() external isInitialized {
        uint256 nftBalance = escrowNFT.balanceOf(msg.sender);
        require(nftBalance > 0, "No escrow NFTs to redeem.");

        uint256 totalAmount = 0;

        for (uint256 i = 0; i < nftBalance; i++) {
            uint256 tokenId = escrowNFT.tokenOfOwnerByIndex(msg.sender, i);
            (uint256 amount, uint256 matureTime) = escrowNFT.tokenDetails(tokenId);

            if (matureTime <= block.timestamp) {
                escrowNFT.burn(tokenId);
                totalAmount += amount;
            }
        }

        require(totalAmount > 0, "No Ether to redeem.");

        (bool success, ) = msg.sender.call{value: totalAmount}("");

        require(success, "Transfer failed.");

        emit Redeemed(msg.sender, totalAmount);
    }

    function contractAddress() public view returns (address) {
        return address(this);
    }
}
