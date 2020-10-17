pragma solidity >=0.4.21 <0.7.0;

import "./SafeMath.sol";
import "./Ownable.sol";


// Contarct Interface /////////////////////////////////////////////////////////////////////////////////////////////

contract TokenInterface {
    
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address _from, address to, uint256 value) public returns (bool);
}

/// @title Name Auction
/// @author Gonzalo Munilla Garrido
/// @notice This smart contract hosts an auction for names set by the owner of this contract

contract Auction is Ownable {
    
    // Libraries /////////////////////////////////////////////////////////////////////////////////////////////

    using SafeMath for uint256;
    
    // Constants /////////////////////////////////////////////////////////////////////////////////////////////
    
    /// @param WaitingTime the amount of seconds the auction lasts
    uint WaitingTime = 180;

    // Mappings /////////////////////////////////////////////////////////////////////////////////////////////
    
    /// @param NameToBool It keeps track of the names the owner has set, that way he/she cannot set the names anew
    mapping(string => bool) NameToBool;
    
    /// @param This maps a name to a struct containing the information of this name, the highgest bidder/owner, the timelimit and its highest bid
    mapping(string => Data) NameToOwner;

    // Contarct Interface Assignment /////////////////////////////////////////////////////////////////////////////////////////////
    
    /// @param token Object to use the functions form the token contract whose funds are used for this auction
    TokenInterface token;
    
    // Events /////////////////////////////////////////////////////////////////////////////////////////////
    
    /// @notice NewName this event is triggered every time a new name is posted for auctioning
    event NewName(string name, uint cost, string text);
    /// @notice NewBid this event is triggered every time a new bid is made for a specific name
    event NewBid(string name, uint bid, uint TimeRemaining, string text);
    
    // Modifiers /////////////////////////////////////////////////////////////////////////////////////////////
    
    /// @notice OnlyOnTime only if the call of the function is within the auction time, the transaction will be executed
    modifier OnlyOnTime(string memory name) {
    
        require(now < NameToOwner[name].TimeLimit, "The auction has finished.");
        _;
    }
    
    /// @notice OnlyAfterTime only if the call of the function is after the auction time, the transaction will be executed
    modifier OnlyAfterTime(string memory name) {
    
        require(now > NameToOwner[name].TimeLimit, "The auction is not yet finished.");
        _;
    }
    
    /// @notice OnlyGreaterBid only if the bid proposed is higher than the previous bid the transaction will be executed
    modifier OnlyGreaterBid(string memory name, uint amount) {
    
        require(amount > NameToOwner[name].HighestBid, "The transfered amount is not greater than the current bid");
        _;
    }

    // Structs /////////////////////////////////////////////////////////////////////////////////////////////
    
    /// @param Data struct containing the necessary information of a name
    /// @param HighestBid number indicating the latest and highest bid made for a specific  name
    /// @param TimeLimit the time in the future in which the auction for that name will be closed 
    /// @param HighestBidder the address of the entity who bid the highest for a specific name
    struct Data {
        
        uint HighestBid;
        uint TimeLimit;
        address HighestBidder;
    }

    // Functions /////////////////////////////////////////////////////////////////////////////////////////////

    /// @notice setTokenContractAddress sets the ocntract address of the token interface, that way its tokens can be used
    function setTokenContractAddress(address ContractAddress) public onlyOwner {
        
        token = TokenInterface(ContractAddress);
    }
    
    /// @notice setName the owner of this contract sets the name to be bid for
    /// @param name the name to be bid for
    /// @param cost the number at which the bid starts, the following bids need to be above such a number
    function setName(string memory name, uint cost) public onlyOwner {
        
        require(!NameToBool[name], "You have already created this name.");
        NameToBool[name] = true;
        
        NameToOwner[name].HighestBidder = owner();
        NameToOwner[name].HighestBid = cost;
        NameToOwner[name].TimeLimit = now.add(WaitingTime);
        
        emit NewName(name, cost, "New name for the taking!");
    }
    
    /// @notice Bid the bidder calls this function to place an amount of tokens as a new highestr bid
    /// @param amount the new bid
    function Bid(uint amount, string memory name) public OnlyOnTime(name) OnlyGreaterBid(name, amount) {
        
        if (msg.sender != owner()) {
            
            require(token.transfer(NameToOwner[name].HighestBidder, NameToOwner[name].HighestBid), "This error is caused by the owner of this contract. Try later.");
        }
        
        require(token.transferFrom(msg.sender, address(this), amount), "You have not allowed this contract to withdraw funds.");
        
        NameToOwner[name].HighestBidder = msg.sender;
        NameToOwner[name].HighestBid = amount;
        
        emit NewBid(name, amount, NameToOwner[name].TimeLimit.sub(now), "New bid!");
    }
    
    /// @notice finishAuction the owner of the ocntract can finish a bid for a name after it is finished
    function finishAuction(string memory name) public onlyOwner OnlyAfterTime(name){
        
        require(token.transfer(owner(), NameToOwner[name].HighestBid));
        NameToOwner[name].HighestBid = 0;
    }
    
    /// @notice getCost this function retrieves the actual cost of a name in the auction
    function getCost(string calldata name) external view returns (uint) {
        
        return NameToOwner[name].HighestBid;
    }
    
}