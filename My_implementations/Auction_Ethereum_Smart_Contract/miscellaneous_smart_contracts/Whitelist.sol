pragma solidity >=0.4.22 <0.6.0;

import "./Ownable.sol";


contract Whitelist is Ownable {
   
   
    ///// MAPPINGS ////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////
   
    // MAKE THEM internal, thus they cannot be check with a built-in getter function
    mapping (address => bool) internal BidderAddr;
    mapping (address => bool) internal CallerAddr;
    mapping (address => bool) internal EVSEAddress;
    mapping (address => bool) internal SMAddress;

    //// CONSTRUCTOR ////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
   
    constructor () public {
       
        CallerAddr[owner()] = true;
    }
   
    ///// FUNCTIONS ////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////
   
   
    function setWhitelistEVSE (address[] memory _users) public onlyOwner { // Change to internal later
       
        for (uint i = 0; i < _users.length; i++) {
           
            EVSEAddress[_users[i]] = true;
        }
    }
   
    function setWhitelistBidders (address[] memory _users) public onlyOwner { // Change to internal later
       
        for (uint i = 0; i < _users.length; i++) {
           
            BidderAddr[_users[i]] = true;
        }
    }
   
    function setWhitelistCallers (address[] memory _users) public onlyOwner {
       
        for (uint i = 0; i < _users.length; i++) {
           
            CallerAddr[_users[i]] = true;
        }
    }
   
    function setWhitelistSMs (address[] memory _users) public onlyOwner {
       
        for (uint i = 0; i < _users.length; i++) {
           
            SMAddress[_users[i]] = true;
        }
    }
   
    function cancelPermission_of_SM (address _user) public onlyOwner {
       
        SMAddress[_user] = false;
    }
   
    function cancelPermission_of_Bidder (address _user) public onlyOwner {
       
        BidderAddr[_user] = false;
    }
   
    function cancelPermission_of_Caller (address _user) public onlyOwner {
       
        CallerAddr[_user] = false;
    }
   
    function cancelPermission_of_EVSE (address _user) public onlyOwner {
       
        EVSEAddress[_user] = false;
    }
   
    // This is done because there is a function that checks the SM in the middle of a function, not only before executing it, thus it cannotbe a modifier
    function verifySM (address _user) external view returns (bool) {
       
        return SMAddress[_user];
    }
   
    // This is done because there is a function that checks the SM in the middle of a function, not only before executing it, thus it cannotbe a modifier
    function verifyBidder (address _user) external view returns (bool) {
       
        return BidderAddr[_user];
    }

}
