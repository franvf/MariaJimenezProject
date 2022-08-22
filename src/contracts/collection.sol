// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../../node_modules/@openzeppelin/contracts/utils/Strings.sol";

contract MariaCollection is ERC721, Ownable {
    //Variables
    address recipient = 0x95B1469584452d8a8d92c959A3A30237D849Eeee; //(*****Modify*****) Recipient of 25% 
    string baseURI = ""; //***** Set baseURI *****

    //Mappings
    mapping (uint256 => bool) isFirstSale; //Mapping to control if is the token first sale

    //Events
    event tokenSold(uint256, address); //Event emited when token is sold

    constructor() ERC721("MariaJimenezCollection", "MJC"){ //***** Modify Collection's Name *****
    }

    //minting function
    function mint(address to, uint256 tokenId) external onlyOwner{
        isFirstSale[tokenId] = true;
        _mint(to, tokenId); //***** Modify "to" to Maria's address ***** Call mint function
    }

    //Sell token function
    function buyToken(uint256 tokenId, uint256 tokenPrice) external payable {
        address payable currentOwner = payable(ownerOf(tokenId));
        
        //***** Check price off-chain or on-chain? *****
        require(tokenPrice * 1 ether == msg.value, "Price is not correct");
        
        if(isFirstSale[tokenId]){  //Check if is the first sale for this token
            isFirstSale[tokenId] = false; //Update firstSale mapping
            firstSale(payable(recipient), msg.value, currentOwner); //Call firstSale function
        } else { //If is not the first sale
            uint256 royaltie = (msg.value * 250/100)/100; //Get 2.5% of sale
            uint256 ownerPart = msg.value - royaltie; //Get the 97.5% of sale
            
            (bool sent, bytes memory data) = currentOwner.call{value: ownerPart}(""); //Pay 97.5% to the NFT owner
            require(sent, "Owner's transaction failed");

            (sent, data) = payable(recipient).call{value: royaltie}(""); //Pay 2.5% to marketplace owner
            require(sent, "Royaltie's transaction failed");
        }     

        //***** Calling smart contract marketplace for approve and transfer the NFT ******

        //emit event to notify the sale
        emit tokenSold(tokenId, msg.sender);
    }


    //Transfer to our wallet 25% of first sale
    function firstSale(address payable to, uint256 totalPrice, address payable tokenOwner) private {
        uint256 firstPart = (25 * totalPrice)/100; //Calculate 25% of sale price
        uint256 secondPart = totalPrice - firstPart; //Calculate 75% of sale price
        
        (bool sent, bytes memory data) = to.call{value: firstPart}(""); //Transfer 25% to "to" account
        require(sent, "First transaction failed");
        
        (sent, data) = tokenOwner.call{value: secondPart}(""); //Transfer 75% to tokenOwner account
        require(sent, "Second transaction failed");
    } 

    //Function to get the tokenURI of each token
    function tokenURI(uint256 tokenId) public view override returns(string memory){
        return string(abi.encodePacked(baseURI, "/", tokenId, ".json"));
    }

    //Function to modify the base URI
    function modifyURI(string memory newURI) external onlyOwner {
        baseURI = newURI;
    }

    //SetApprovalForAll¿? -> Avoiding sales in markets other than ours
    //burn¿?


}
