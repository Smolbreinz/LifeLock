//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


import "../dependencies/IERC721Receiver.sol";
import "../dependencies/IERC721.sol";
import "../dependencies/IERC20.sol";
import "../dependencies/Types.sol";



/* @dev: User Safe contract owned by the user.
    Enables User to protect tokens to be 
    withdrawable by the recipient as well
    as the recipient to withdraw the tokens */

contract MLegacy {


    address public immutable owner;
    address public immutable recipient;
    uint public payday; //point in time after which nthe assets are withdrawable by the recipient

    mapping (address => bool) public whitelist;
    // whitelist for address who can initiate the withdraw function to 
    // transfer the assets to the recipient

    constructor (address _owner, address _recipient) {
        owner = _owner;
        recipient = _recipient;
        whitelist[_owner] = true;
        whitelist[_recipient] = true;
        payday = block.timestamp + 20 minutes; // default timeframe for testing purposes
    }

    event addedProtectedToken(IERC20 token, uint amount);
    event TransferProtectedAssets(address sender, address indexed token, address indexed recipient, uint256 amount);
    event periodSet(address indexed owner, address indexed recipient, uint timestamp, uint indexed payday);
    event whitelistAdded(address whitelistedAddress, uint timestamp);
    event removeAddress(address removedAddress, uint timestamp);
    event tokenProtected(IERC20 token, address mLegacy, address owner);


    modifier onlyOwner () {
        require(msg.sender == owner, "only the owner can call this function");
        _;
    }

    modifier onlyWhitelist () {
        require(whitelist[msg.sender], "only whitelisted users can call this function");
        _;
    }

     struct protectedERC20{
        string name;
        IERC20 token;

     //object to be stored 
     }


     protectedERC20 [] public safe; 
    //stores all the protectedERC20s to be approved to be spent by this contract



    function setWhitelistAddress(address _whitelist) external onlyOwner {
        require(!whitelist[_whitelist], "the address you are trying to add is already on the whitelist");
        whitelist[_whitelist] = true;

        emit whitelistAdded(_whitelist, block.timestamp);

    //add/remove whitelist addresses who can call the withdraw function

    }

    function removeWhitelistAddress(address _whitelist) external onlyOwner{
        require(whitelist[_whitelist], "the address you are trying to remove is not on the whitelist");
        whitelist[_whitelist] = false;

        emit removeAddress(_whitelist, block.timestamp);
    }

    function getSafe () public view returns (protectedERC20 [] memory) {
        protectedERC20 [] memory _safe = new protectedERC20 [] (safe.length);
        uint count=0;
        
        for (uint i = 0; i < safe.length; i++) {
            _safe[count] = safe[i];
            count++;
        }

        protectedERC20 [] memory result = new protectedERC20 [] (count);
        for (uint i = 0; i < count; i++){
            result[i] = _safe[i];
        }
        
        return result;

    // returns the protected Tokens to the recipient for him to withdraw them
    }

    //add asset to protectedERC20s
    function protectERC20 (string memory _name, IERC20 _token) external onlyOwner {
        bool tokenFound = false;

        for (uint i = 0; i< safe.length; i++){
            if (_token == safe[i].token){
                tokenFound = true;
                break;
            }  
        }
        if(!tokenFound){
         protectedERC20 memory _protectedERC20 = protectedERC20({
                name: _name,
                token: _token
            });
            safe.push(_protectedERC20);
        }
        
        emit tokenProtected(_token, address(this), msg.sender);

    // adds an ERC20 token selected by the owner to the safe array
    }

    // set the period until the asstes are to be transfered
    function setPayday(uint _period) external onlyOwner{
        payday = block.timestamp + _period;

       emit periodSet(msg.sender, recipient, block.timestamp, payday);

    // sets the period after which an asset is withdrawable
    }

    function failSafe(IERC20 _token, uint _amount) external onlyWhitelist{
        require(block.timestamp > payday, "the period until an asset transfer is possible has not been completed yet");
        _token.transferFrom(owner, recipient, _amount);

    //transfer function called by the recipient or any other whitelisted user.
    // @params: the amount transferred is the allowance that is fetched in the frontend
    //          to automatically allow the user to transfer the maximum amount possible
    }

    receive() external payable {}

   



}


