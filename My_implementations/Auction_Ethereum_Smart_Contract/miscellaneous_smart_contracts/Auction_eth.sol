pragma solidity >=0.4.21 <0.7.0;

import "./SafeMath.sol";

contract Auction {
    
    // Library for safe mathematical operations
    using SafeMath for uint256;
   
    // @param owner stores the contract owner
    address payable owner;
    // @param participant_to_bool stores the clist of allowed participants
    mapping (address => bool) public participant_to_bool;
    // @param bid_status indicates whether the auction is finished
    enum bid_status {open, closed}
   
    // @param Offer stores new offers
    struct auctioned_item { 
      // @param item string containing the name of the auctioned item
      string item;
      // @param price uint containing the initial price and posterior highest bids
      uint price;
      // @ param highes_bidder the latest bidder with the highest bid
      address payable highest_bidder; 
      // @ param status enum indicating whether the auction is open or closed
      bid_status status;
    }
    
    // @param auctioned_items stores an array of auctioned items
    auctioned_item[] public auctioned_items;
    
    // @notice offerPosted this event is triggered every time a new item is open for auctioning
    event itemAuctionStart(string item, uint price, uint index, address auctioneer, string text); 
    // @notice newBid this event is triggered every time a new bid is made for an item
    event newBid(string item, uint bid, uint index, address bidder, string text); 
    // @notice finishedAuction this event is triggered every time an auction is finished
    event finishedAuction(string item, uint price, uint index, address bidder, string text);
    
    modifier onlyOwner() { 
      require(owner == msg.sender);                                                                 // 1. check if owner
      _;                                                                                            // 2. continue with method
    }
    
    modifier notOwner() { 
      require(owner != msg.sender);                                                                 // 1. check if not owner
      _;                                                                                            // 2. continue with method
    }
    
    modifier onlyParticipant() {
        
      require(participant_to_bool[msg.sender]);                                                    // 1. check if participant
      _;                                                                                            // 2. continue with method
    }
    
    constructor () public {
        
        owner = msg.sender;                                                                         // 1. set owner
    }
    

     
    // @notice setParticipant sets new participant in the participant list
    function setParticipant( address participant ) public onlyOwner {
    
        participant_to_bool[participant] = true;                                                     // 1. set new participant in the whitelist 
    }


    // @notice setAuctionedItem the owner of the auction sets a new item for auction
    function setAuctionedItem(string memory item, uint price) public onlyOwner { 
      
        auctioned_items.push(auctioned_item(item, price, address(0), bid_status.open));               // 1. owner sets a new item for auctionning
        uint index = auctioned_items.length.sub(1);                                                  // 2. calculates index of the new item in the array with safemath
        emit itemAuctionStart(item, price, index, msg.sender, "A new item is being auctioned!" ); 
    }
   
   
    // @notice bid a participant makes a bid for a particular item using its index
    function bid(uint index) public payable onlyParticipant notOwner{
        
        require(msg.value > auctioned_items[index].price, "Your bid is too low.");                  // 1. check whether the ETH sent is greater than the highest bid (or initial price) (no "text" needed)
        require(auctioned_items[index].status == bid_status.open, "This auction has been closed."); // 2. check whether the auction is finalized (no "text" needed)
       
        
        if (auctioned_items[index].highest_bidder != address(0)) {                                  // 3. check whether there was a previous
            
           
            auctioned_items[index].highest_bidder.transfer(auctioned_items[index].price);           // 4. send the ETH from the contract to the bidder with the previous lower bid
            }
       
        auctioned_items[index].highest_bidder = msg.sender;                                         // 5. assign the new highest bidder
        auctioned_items[index].price = msg.value;                                                   // 6. assign the new highest bid
        emit newBid(auctioned_items[index].item, msg.value, index, msg.sender, 'New bid!');
    }
   
    // @notice finishAuction the owner can close the auction at will
    function finishAuction (uint index) public onlyOwner { 
       
        owner.transfer(auctioned_items[index].price);                                               // 1. the auctioneer sends the ETH to himself
        (auctioned_items[index].status = bid_status.closed);                                        // 2. Close auction
        accountBalances[auctioned_items[index].highest_bidder].bidder_balance = 0;                  // 3. resets the account balance of the highest bidder to 0. (1 p)
        emit finishedAuction(auctioned_items[index].item, auctioned_items[index].price, index, auctioned_items[index].highest_bidder, 'Auction finished!');
    }
    
    //////    //////    //////    //////    //////
    // USING THE PULL OVER PUSH IDIOM
    //////    //////    //////    //////    //////
    // @param bidder_withdrawal enum with  binary value that indicates whether a bidder is allowed to withdraw his/her funds (based on the identity of the highest bidder)
    enum bidder_withdrawal {allowed, not_allowed}
    
    struct bidder { 
      // @param balance uint containing the balance a bidder has placed in the smart contract
      uint bidder_balance;
      // @ param withdrawal enum containing a binary value of whether the bidder is allowed to withdraw money or not (based on whether the person is the highest bidder)
      bidder_withdrawal withdrawal; 
    }
    
    // @param accountBalances mapping of addresses and the struct bidder, to keep track of the balance of each bidder and whether they are allowded to withdraw Ether from the contract
    mapping(address => bidder) public accountBalances;
    
    // @notice bid a participant makes a bid for a particular item using its index
    function bid_2(uint index) public payable onlyParticipant notOwner{
        
        require(msg.value > auctioned_items[index].price, "Your bid is too low.");                  // 1. check whether the ETH sent is greater than the highest bid (or initial price) (no "text" needed)
        require(auctioned_items[index].status == bid_status.open, "This auction has been closed."); // 2. check whether the auction is finalized (no "text" needed)
       
        if (auctioned_items[index].highest_bidder != address(0)) {                                  // 3. check whether there was a previous bidder
            
            accountBalances[auctioned_items[index].highest_bidder].withdrawal =  bidder_withdrawal.allowed;    // 4.The previous bidder is now allowed to withdraw the funds he previously submitted
            }
        
       
        auctioned_items[index].highest_bidder = msg.sender;                                         // 5. assign the new highest bidder
        auctioned_items[index].price = msg.value;                                                   // 6. assign the new highest bid
        accountBalances[msg.sender].bidder_balance = accountBalances[msg.sender].bidder_balance.add(auctioned_items[index].price);  // 7. update the balance of the bidder (Mind the sum, as perhpas the bidder has not withdraw yet the previos amount)
        accountBalances[msg.sender].withdrawal = bidder_withdrawal.not_allowed;                     // 8. The highest bidder is not allowed to withdraw ether
        emit newBid(auctioned_items[index].item, msg.value, index, msg.sender, 'New bid!');
    }
    
    // @notice withdraw allows to withdraw ether from the smart contract to anyone who transfered money
    function withdraw() public {
        
        uint amount = accountBalances[msg.sender].bidder_balance;                                                  
        require(amount != 0);                                                                       // 1. The amount must be different to 0
        require(address(this).balance >= amount);                                                   // 2. The balance of the contract must be larger than the amount to withdraw (safety check)
        require(accountBalances[msg.sender].withdrawal == bidder_withdrawal.allowed);               // 3. The bidder cannot be the highest bidder
        accountBalances[msg.sender].bidder_balance = 0;                                             // 4. We reset the balance of the bidder
        msg.sender.transfer(amount);                                                                // 5. We transfer all the balance tot he respective bidder
    }
}