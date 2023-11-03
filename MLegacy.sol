//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


import "../dependencies/IERC721Receiver.sol";
import "../dependencies/IERC721.sol";
import "../dependencies/IERC20.sol";
import "../dependencies/Types.sol";



contract MLegacy {


    address public immutable owner;
    address public immutable recipient;
    uint public payday;
    uint public tokenCount = 0;

    mapping (address => bool) public whitelist;
    mapping (IERC20 => bool) public safeTokens;
    mapping (uint => protectedERC20) public safeTokensIndices;

    constructor (address _owner, address _recipient) {
        owner = _owner;
        recipient = _recipient;
        whitelist[_owner] = true;
        whitelist[_recipient] = true;
        payday = block.timestamp + 20 minutes;
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

    //object to be stored 
    struct protectedERC20{
        string name;
        IERC20 token;
    }


    function setWhitelistAddress(address _whitelist) external onlyOwner {
        require(!whitelist[_whitelist], "the address you are trying to add is already on the whitelist");
        whitelist[_whitelist] = true;

        emit whitelistAdded(_whitelist, block.timestamp);

    }

    function removeWhitelistAddress(address _whitelist) external onlyOwner{
        require(whitelist[_whitelist], "the address you are trying to remove is not on the whitelist");
        whitelist[_whitelist] = false;

        emit removeAddress(_whitelist, block.timestamp);
    }


    function protectERC20_2 (IERC20 _token, string memory name) external onlyOwner {
        require (_token != IERC20(address(0)), "token to be protected cannot be the zero address");
        if (safeTokens[_token] == true){
            revert("The Token you are trying to add is already stored in your Safe");
        } else {
            safeTokens[_token] = true;
            safeTokensIndices[tokenCount] = protectedERC20({name: name, token: _token});
            tokenCount++;

            emit tokenProtected(_token, address(this), msg.sender);

        }
    }

    function getSafe_2 () external view returns (protectedERC20 [] memory){
        protectedERC20 [] memory safeArray = new protectedERC20 [] (tokenCount);
        for (uint i = 0; i < tokenCount; i++){
            safeArray[i] = safeTokensIndices[i];
        }
        return safeArray;
    }


    // set the period until the asstes are to be transfered
    function setPayday(uint _period) external onlyOwner{
        payday = block.timestamp + _period;
       //legacyFactory.modifyMatches(recipient);

       emit periodSet(msg.sender, recipient, block.timestamp, payday);
    }

    //this function can trigger the manual transfer of each token in case the automated transaction has failed
    function failSafe(IERC20 _token, uint _amount) external onlyWhitelist{
        require(block.timestamp > payday, "the period until an asset transfer is possible has not been completed yet");
        _token.transferFrom(owner, recipient, _amount);
    }

    receive() external payable {}
    

}


