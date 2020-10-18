pragma solidity >=0.4.21 <0.7.0;

interface TokenInterface {
   
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address _from, address to, uint256 value) external returns (bool);
}

contract Auction {
   
    // @param owner stores the contract owner
    address owner;
    // @param participant_to_bool stores the clist of allowed participants
    mapping (address => bool) public participant_to_bool;
    // @param bid_status indicates whether the auction is finished
    enum bid_status {open, closed}
    // @param token holds the address of the token contract address and uss the defined interface
    TokenInterface token;
   
    // @param Offer stores new offers
    struct auctioned_item { 
        // @param item string containing the name of the auctioned item
        string item;
        // @param price uint containing the initial price and posterior highest bids
        uint price;
        // @ param highes_bidder the latest bidder with the highest bid
        address highest_bidder; 
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
    
    // @notice setTokenContractAddress sets the adress for the tokens to be used
    function setTokenContractAddress(address ContractAddress) public onlyOwner {
       
        token = TokenInterface(ContractAddress);
    }
    
    // @notice setParticipant sets new participant in the participant list
    function setParticipant( address participant ) public onlyOwner {
    
       participant_to_bool[participant] = true;                                                     // 1. set new participant in the whitelist 
    }


    // @notice setAuctionedItem the owner of the auction sets a new item for auction
    function setAuctionedItem(string memory item, uint price) public onlyOwner { 
      
      auctioned_items.push(auctioned_item(item, price, address(0), bid_status.open));               // 1. owner sets a new item for auctionning
      uint index = auctioned_items.length - 1;                                                      // 2. calculates index of the new item in the array
      emit itemAuctionStart(item, price, index, msg.sender, "A new item is being auctioned!" ); 
    }
   
    // @notice bid a participant makes a bid for a particular item using its index
    function bid(uint index, uint bid_amount) public onlyParticipant notOwner {
     
        require(bid_amount > auctioned_items[index].price, "Your bid is too low.");             // 1. check whether the ETH sent is greater than the highest bid (or initial price) (no "text" needed)
        require(auctioned_items[index].status == bid_status.open, 
        "This auction has been closed.");                                                       // 2. check whether the auction is finalized (no "text" needed)
       
         
        if (auctioned_items[index].highest_bidder != address(0)) {                              // 3. check whether there was a previous bidder
           
            require(token.transfer(auctioned_items[index].highest_bidder, 
            auctioned_items[index].price));                                                     // 4. send the tokens from the contract to the bidder with the previous lower bid
        }
        
        require(token.transferFrom(msg.sender, address(this), bid_amount), 
        "You have not allowed this contract to withdraw funds.");                               // 5. the smart contract transfers the tokens of the new highest bidder to itself
        
        auctioned_items[index].highest_bidder = msg.sender;                                     // 6. assign the new highest bidder
        auctioned_items[index].price = bid_amount;                                              // 7. assign the new highest bid
        emit newBid(auctioned_items[index].item, bid_amount, index, msg.sender, 'New bid!');
        
            
    }
   
    // @notice finishAuction the owner can close the auction at will
    function finishAuction (uint index) public onlyOwner { 
       
        token.transfer(owner, auctioned_items[index].price);                                     // 1. the auctioneer sends the tokens to herself/himself
        auctioned_items[index].status = bid_status.closed;                                       // 2. Close auction
        emit finishedAuction(auctioned_items[index].item, auctioned_items[index].price, index, auctioned_items[index].highest_bidder, 'Auction finished!');
    }
}