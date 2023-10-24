//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./ALegacy.sol";
import "./MLegacy.sol";


// @dev: contract factory that creates
//       the user safe contract.
//       Currently still contains the code for the "automate" 
//       functionality, which will be removed in the next version


contract LegacyFactory {
    
    
    address payable public owner;
    address payable automateAddress;

   // mapping (address => bool) legacies;


    constructor (address payable _automateAddress) {
        owner = payable(msg.sender);
        automateAddress = _automateAddress;

    /* takes the address of the gelato automate contract.
        this will be removed in the next version as it does not represent
        the desired functionality anymore 
    */

    }

    modifier onlyOwner () {
        require(msg.sender == owner, "only the owner of the contract can call this function");
        _;
    }

    event manualUserSafeCreated(address owner, address payable recipient, uint timestamp, address mlegacy);
    event autoUserSafeCreated(address owner, address payable recipient, uint timestamp, address alegacy);

    // events emitted upon the creation of an MLegacy contract by a user

    struct recipients {
        address owner;
        address legacy;
        address recipient;

    // stores the owner, the owners MLegacy contract address and the recipient (beneficiary)
    // of the MLegacy contract named by the owner
    }


    recipients [] public matches;

    // stores recipient structs for all created MLegacy contracts
    

    function getOwnerMatches() public view returns (address){

        for (uint i = 0; i < matches.length; i++){
            if(msg.sender == matches[i].owner){
                return matches[i].legacy;
            }
        }
        return address(0);

    // returns the contract of an MLegacy if called by the owner of an MLegacy contract

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

    // returns all MLegacies for a specific recipient calling this function.
    }

    
    function createUserSafe(address payable recipient, bool automate) external {
        bool ownerExists = false;

        for (uint i = 0; i< matches.length; i++){
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

    // called by user to create a new MLegacy contract
    // the automate function is deprecated and will be removed in the next version
    // takes the address of the desired recipient and adds the created MLegacy to the
    // recipients array.
    // requires that the user address calling this function does not already own an MLegacy
    // to prevent multiple MLegacies per user

    }

    receive() external payable {}
    fallback() external payable {}

    function withdraw () public onlyOwner {
       payable(owner).transfer(address(this).balance);
    }

}

