// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Company is ERC1155, Ownable, ERC1155Supply, ReentrancyGuard{

    IERC20 public usdcToken;

    uint256 public constant SHARE = 0;
    uint256 public askingPrice = 1000;
    
    
    // if you want multiple properties in the same contract, we work with a mapping
    //mapping(uint256 => uint256) public pricePerProperty;

    
    constructor(address _multisigWallet, address usdcAddress) ERC1155("") {
        transferOwnership(_multisigWallet);
        usdcToken = IERC20(usdcAddress);
        _mint(msg.sender,SHARE,100); 
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function setAskingPrice(uint256 property, uint256 _askingPrice) public onlyOwner{
        askingPrice = _askingPrice;
        //pricePerProperty[property] = _askingPrice;
    }


    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // for simplicity sake, you can only buy one share atm.
    // if you'd like to buy more, we can add and amount to to the buyShare function
    function buyShare(/*uint256 amount*/) external payable {
       require(usdcToken.balanceOf(msg.sender)>= askingPrice * amount, "Insufficient funds");
       require(usdcToken.allowance(msg.sender,address(this)) >= askingPrice * amount,"Insufficient allowance")

       transferFrom(msg.sender,address(this),askingPrice);
    }


    function withdraw() public onlyOwner(){
        
    }
}
