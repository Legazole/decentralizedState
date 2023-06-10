// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
//import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

contract Property is ERC1155,Ownable, ReentrancyGuard{

    event SharePurchased(address buyer, uint256 _property, uint256 amount);

    struct TokenMetadata {
        string uri;
    }

    IERC20 public usdcToken;

    uint256 public constant SHARE0 = 0;
    uint256 public constant SHARE1 = 1;

    
    // if you want multiple properties in the same contract, we work with a mapping
    mapping(uint256 => uint256) public pricePerProperty;

    mapping(uint256 => TokenMetadata[]) private tokenMetadata;
    
    constructor(address _multisigWallet, address usdcAddress, uint256 _askingPrice0, uint256 _askingPrice1) ERC1155("") {
        transferOwnership(_multisigWallet);
        usdcToken = IERC20(usdcAddress);
        //_mintAndSetMetadata();
        _mint(msg.sender,SHARE1,100,"");
        pricePerProperty[SHARE0] = _askingPrice0;
        _mint(msg.sender,SHARE0,100,"");
        pricePerProperty[SHARE1] = _askingPrice1;

    }


    function _mintAndSetMetadata(
        address account,
        uint256 tokenId,
        uint256 amount,
        string memory tokenURI
    ) internal {
        _mint(account, tokenId, amount,"");
        _setTokenURI(tokenId, amount - 1, tokenURI);
    }

    
    function _setTokenURI(uint256 tokenId, uint256 index, string memory tokenURI) internal {
        require(index < tokenMetadata[tokenId].length, "Invalid token index");
        tokenMetadata[tokenId][index].uri = tokenURI;
        // Emit an event or perform any additional actions
    }

    /*
    function updateTokenURI(uint256 tokenId, uint256 index, string memory newTokenURI) external {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Caller is not approved or owner of the token");
        require(index < tokenMetadata[tokenId].length, "Invalid token index");
        tokenMetadata[tokenId][index].uri = newTokenURI;
        // Emit an event or perform any additional actions
    }
    */
   
    function getPriceForPropertyShare(uint256 _property) external view returns(uint256){
        return pricePerProperty[_property];
    }

    function getBalanceOfPropertyForAddress(uint256 _property, address _address)external view returns(uint256){
        return balanceOf(_address,_property);
    }

    function setAskingPrice(uint256 property, uint256 _askingPrice) external onlyOwner{
        pricePerProperty[property] = _askingPrice;
    }


    function buyShare(uint256 _property, uint256 _amount) external nonReentrant {
        require(_amount > 0 && _amount <= balanceOf(address(this),_property), "Insufficient shares");
        
        uint256 totalPrice = pricePerProperty[_property] * _amount;
    
       require(usdcToken.balanceOf(msg.sender)>= totalPrice, "Insufficient funds");
       require(usdcToken.allowance(msg.sender,address(this)) >= totalPrice* _amount,"Insufficient allowance");

       bool usdcTradeSucces = usdcToken.transferFrom(msg.sender,address(this),totalPrice);
       require(usdcTradeSucces,"USDC transfer failed");

       safeTransferFrom(address(this),msg.sender,_property,_amount,"");

       require(balanceOf(msg.sender, _property) >= _amount);

       emit SharePurchased(msg.sender,_property,_amount);

    }


    function buyShares(uint256[] memory _properties, uint256[] memory amounts) external {

    }

    function transferShare() external{

    }

    function sellShare() external {

    }

    function withdraw() external onlyOwner{

    }
}
