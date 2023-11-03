//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./MLegacy.sol";

contract LegacyFactory {
    
    
    address payable public owner;


   mapping (address => address) public owners;

   mapping (address => address) public recipients_1;
   mapping (address => address) public recipients_2;
   mapping (address => address) public recipients_3;


    constructor () {
        owner = payable(msg.sender);
    }

    modifier onlyOwner () {
        require(msg.sender == owner, "only the owner of the contract can call this function");
        _;
    }

    event manualUserSafeCreated(address owner, address recipient, uint timestamp, address mlegacy);

    
    //called by user to create a new safe
    function createUserSafe(address recipient) external {
        bool ownerExists = false;
        bool recipient1Exists = false;
        bool recipient2Exists = false;
        bool recipient3Exists = false;

        if (recipients_1[recipient] != address(0)){
            recipient1Exists = true;
        }

        if (recipients_2[recipient] != address(0)){
            recipient2Exists = true;
        }

        if (recipients_3[recipient] != address(0)){
            recipient3Exists = true;
        }

        if(owners[msg.sender] != address(0)){
            ownerExists = true;
        }

        require(!ownerExists, "The wallet you are trying to protect already has a protection contract");

        if(recipient1Exists && recipient2Exists && recipient3Exists){
            revert("the chosen recipient has already been selected as recipient for three other smart contracts");
        } else {
            if(recipient1Exists && recipient2Exists){
                MLegacy mlegacy = new MLegacy(msg.sender, recipient);
                owners[msg.sender] = address(mlegacy);
                recipients_3[recipient] = address(mlegacy);
                emit manualUserSafeCreated(msg.sender, recipient, block.timestamp, address(mlegacy));

            } else {
                if(recipient1Exists) {
                    MLegacy mlegacy = new MLegacy(msg.sender, recipient);
                    owners[msg.sender] = address(mlegacy);
                    recipients_2[recipient] = address(mlegacy);
                    emit manualUserSafeCreated(msg.sender, recipient, block.timestamp, address(mlegacy));

                } else {
                    MLegacy mlegacy = new MLegacy(msg.sender, recipient);
                    owners[msg.sender] = address(mlegacy);
                    recipients_1[recipient] = address(mlegacy);
                    emit manualUserSafeCreated(msg.sender, recipient, block.timestamp, address(mlegacy));

                }
            }
        }            

    }
       
    
    receive() external payable {}
    fallback() external payable {}

    function withdraw () public onlyOwner {
       payable(owner).transfer(address(this).balance);
    }

}

