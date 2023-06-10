// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

contract Property is ERC1155URIStorage,Ownable, ReentrancyGuard{

    event SharePurchased(address buyer, uint256 share);
    event ShareTransferred(address from, address to, uint256 share);
    event ShareSold(address from,address to, uint256 share);
    event Withdrawal(address to, uint256 amount);
    event UpdateURI(address receiver,uint256 share);

    IERC20 public usdcToken;

    uint256 public counter = 0;
    mapping(uint256 => uint256) public pricePerShare;

    
    constructor(address _multisigWallet, address usdcAddress, uint256 _askingPrice, uint256 _amountOfShares, string memory baseURI) ERC1155(baseURI) {
        transferOwnership(_multisigWallet);
        usdcToken = IERC20(usdcAddress);

        for (uint i = 0; i < _amountOfShares; i++) {
            _mint(msg.sender,counter,1,"");
            pricePerShare[i] = _askingPrice;
        }
    }

   
    function getPriceForShare(uint256 _share) external view returns(uint256){
        return pricePerShare[_share];
    }

    function doesAddressOwnShare(uint256 _share, address _address)external view returns(bool){
        if (balanceOf(_address,_share) == 0) {
            return false;
        } 
        return true;   
    }

    function setAskingPrice(uint256 _share, uint256 _askingPrice) external onlyOwner{
        pricePerShare[_share] = _askingPrice;
    }

    function buyShare(uint256 _share) external nonReentrant {

        require(balanceOf(address(this),_share) >= 0, "Insufficient shares");

        uint256 totalPrice = pricePerShare[_share];
        
    
       require(usdcToken.balanceOf(msg.sender)>= totalPrice, "Insufficient funds");
       require(usdcToken.allowance(msg.sender,address(this)) >= totalPrice,"Insufficient allowance");

       bool usdcTradeSucces = usdcToken.transferFrom(msg.sender,address(this),totalPrice);
       require(usdcTradeSucces,"USDC transfer failed");

       safeTransferFrom(address(this),msg.sender,_share,1,"");

       require(balanceOf(msg.sender, _share) >= 1);

       emit SharePurchased(msg.sender,_share);
       emit UpdateURI(msg.sender,_share);
    }


    //implement the escrow functionality
    function transferShare(address to, uint256 _share) external{
        require(to != address(0), "Invalid recipient address");

        safeTransferFrom(msg.sender, to, _share, 1, "");

        emit ShareTransferred(msg.sender, to, _share);
        emit UpdateURI(to,_share);

    }

    //implement listing functionality
    function sellShare(uint256 _share) external nonReentrant {
        require(balanceOf(msg.sender,_share)>0);
        safeTransferFrom(msg.sender,address(this),_share,1,"");

        //implement transfer from contract to seller
        //look into LP for instant selling liquidity

        emit ShareSold(msg.sender,address(this),_share);
        emit UpdateURI(address(this),_share);
    }

   function withdraw() external onlyOwner {
        uint256 contractBalance = usdcToken.balanceOf(address(this));
        require(contractBalance > 0, "No balance to withdraw");

        bool success = usdcToken.transfer(owner(), contractBalance);
        require(success, "USDC transfer failed");

        emit Withdrawal(owner(), contractBalance);
    }

    function _setShareURI(uint256 _share, string memory tokenURI) external onlyOwner{
        _setURI(_share, tokenURI);
    }
}
