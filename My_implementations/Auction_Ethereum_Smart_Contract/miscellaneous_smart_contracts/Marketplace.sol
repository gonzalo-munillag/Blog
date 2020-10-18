pragma solidity >=0.4.21 <0.7.0;

import "./Ownable.sol";

// The contract inherits from Onlyowner, a standardize Smart contract used to create a modifier which allows only the deployer (auctioneer) of the contract to call the function
contract Marketplace is Ownable {
   
    enum BidStatus {Open, Closed}
   
    // Struct used to store new offers. Stack together the same variable typs for space efficiency and cost
    struct Offer {
      uint Power;
      uint Duration;
      uint Price;
      string offer;
      address payable HighestBidder; // It needs to be payable for the contract to send ether to this address
      BidStatus Status;
    }
   
    mapping ( address => Offer[] ) public SellerToOffer; // Used to keep track of each of the offers from every seller
    mapping ( address => bool) public ParticipantToBool; // A whitelist of participants, only they are allowed to sell or buy
   
    event OfferPosted( string offer, uint Power, uint Duration, uint Price, uint index, address seller, string text ); // This event will be read by the demand side of the market, that way they are informed of the new offers
   
   
    modifier onlyParticipant( address Participant) { // This modifier will be attached to functions which only the whitelisted addresses can trigger
      require(ParticipantToBool[Participant], "You are not allowed to participate in this market"); // A require acts as an IF statement, printing the string if the condition is not fulfilled
      _;
   
    }
   
    function setParticipant( address Participant ) public onlyOwner { // Only the auctioneer can trigger this function
       ParticipantToBool[Participant] = true;  // A new participantis added to the whitelist
    }
   
    function setOffer( uint Power, uint Duration, uint Price, string memory offer) public onlyParticipant( msg.sender) { // Executed by whitelisted sellers to post a new energy offer
      uint index = SellerToOffer[msg.sender].push( Offer( Power, Duration, Price, offer, address(0), BidStatus.Open ) ); // We push the new offer into the mapping of the corresponding seller
      emit OfferPosted( offer, Power, Duration, Price, index, msg.sender, "A new offer has been posted" ); // We trigger the event for the demand side of the market to read the offer
    }
   
    // This function is called to bid for a specific offer
    function bid (uint index, address seller, uint amount) public payable onlyParticipant(msg.sender) {
       
        require(msg.value > SellerToOffer[seller][index].Price, "Your bid is too low."); // We check whether the Ether sent is greater than the highest bid
        require(SellerToOffer[seller][index].Status == BidStatus.Open, "This offer has been closed."); // We check for a bidder not to bid more incase the auciton has been finalized
       
        if (SellerToOffer[seller][index].HighestBidder != address(0)) { // It will only execute the transfer function if previously there was already a bidder
            SellerToOffer[seller][index].HighestBidder.transfer(SellerToOffer[seller][index].Price); // Refund. We send the ether to the previous bidder
        }
       
        SellerToOffer[seller][index].HighestBidder = msg.sender; // We update the highest bidder
        SellerToOffer[seller][index].Price = msg.value; // We update the higest bid
    }
   
    function finishAuction (uint index, address payable seller) public onlyOwner { // Executed when the auctioneer would like to finish a particular bid
       
        seller.transfer(SellerToOffer[seller][index].Price); // We send the Ether to the seller
        (SellerToOffer[seller][index].Status = BidStatus.Closed); // This way no other bidder can participte
    }

}