//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./ALegacy.sol";
import "./MLegacy.sol";

contract LegacyFactory {
    
    
    address payable public owner;
    address payable automateAddress;

   // mapping (address => bool) legacies;


    constructor (address payable _automateAddress) {
        owner = payable(msg.sender);
        automateAddress = _automateAddress;
    }

    modifier onlyOwner () {
        require(msg.sender == owner, "only the owner of the contract can call this function");
        _;
    }

    event manualUserSafeCreated(address owner, address payable recipient, uint timestamp, address mlegacy);
    event autoUserSafeCreated(address owner, address payable recipient, uint timestamp, address alegacy);


    struct recipients {
        address owner;
        address legacy;
        address recipient;
    }

    recipients [] public matches;

    function getOwnerMatches() public view returns (address){

        for (uint i = 0; i < matches.length; i++){
            if(msg.sender == matches[i].owner){
                return matches[i].legacy;
            }
        }
        return address(0);
    }

    function getMatches(address user) public view returns (address [] memory) {
        address [] memory _legacies = new address [] (matches.length);
        uint count = 0;

        for (uint i = 0; i < matches.length; i++) {
            if (user == matches[i].recipient){
                _legacies[count]= matches[i].legacy;
                count++;
            }
        }
            address [] memory result = new address [] (count);

        for (uint i = 0; i < count; i++) {
            result[i] = _legacies[i];
        }
        return result;
    }

    /*function modifyMatches (address recipient) external {
        require (legacies[msg.sender], "only contract owners can call that function");
         for (uint i = 0; i < matches.length; i++) {
            if (msg.sender == matches[i].legacy){
                matches[i].recipient;
            }
        }
    }*/

    
    //called by user to create a new safe
    function createUserSafe(address payable recipient, bool automate) external {
        bool ownerExists = false;

        for ( uint i = 0; i< matches.length; i++){
            if(matches[i].owner == msg.sender){
                ownerExists = true;
                break;
            }
        }

       if(automate){
        require(!ownerExists, "The wallet you are trying to protect already has a protection contract");
        ALegacy alegacy = new ALegacy(msg.sender, recipient);
            
        
        recipients memory _recipients = recipients({
            owner: msg.sender,
            legacy: address(alegacy),
            recipient: recipient
        });

        matches.push(_recipients);

       // legacies[address(alegacy)] = true;

        emit autoUserSafeCreated(msg.sender, recipient, block.timestamp, address(alegacy));

       } else{
        require(!ownerExists, "The wallet you are trying to protect already has a protection contract");

         MLegacy mlegacy = new MLegacy(msg.sender, recipient);
            

         recipients memory _recipients = recipients({
            owner: msg.sender,
            legacy: address(mlegacy),
            recipient: recipient
        });
            
         matches.push(_recipients);

        //legacies[address(mlegacy)] = true;


         emit manualUserSafeCreated(msg.sender, recipient, block.timestamp, address(mlegacy));

       }
       
    }

    receive() external payable {}
    fallback() external payable {}

    function withdraw () public onlyOwner {
       payable(owner).transfer(address(this).balance);
    }

}

