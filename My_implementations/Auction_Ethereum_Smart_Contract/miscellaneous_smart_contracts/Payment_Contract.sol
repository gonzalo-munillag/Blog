pragma solidity >=0.4.21 <0.7.0;

import "./ECDSA.sol";
import "./SafeMath.sol";

///// INTERFACES ////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
   
abstract contract WhitelistInterface {
   
    function verifySM (address _user) external view returns(bool);
    function verifyBidder (address _user) external view returns(bool);
}

contract DAIInterface {
   
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address _from, address to, uint256 value) public returns (bool);
}

///// CONTRACT /////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

contract PaymentContract {
   
    //// LIBRARIES ////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////
   
    using SafeMath for uint256;
    using ECDSA for bytes32;
   
    ///// CONSTANT INITIALIZATION /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////
   
    uint WaitingTime = 2 days;
   
    // The constructor will later fill in their value
    bytes32 Date_StartTime_Location_bidder_Type; // Used to check cross check with the signed message of the SM which would only know those parameters from the bid
    uint TotalEnergy;
    uint PenaltyAmount;
    uint PaymentAmount;
    uint TimeOfCreation = block.timestamp;
    address bidder;
    address Caller;
    DAIInterface token;
    WhitelistInterface Listing;
    uint PaymentCount;
    uint PenaltyCount;
    uint EnergyCount;
   
    ///// MAPPINGS ////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////
   
    mapping(address => mapping(uint256 => bool)) seenNonces;
   
    ///// EVENTS ////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////
   
    event PenaltyLost(uint Penalty,
                      bytes32 Date_StartTime_Location_bidder_Type,
                      address bidder,
                      string message); // Informs of the lost penalty to the bidder

    event PartialBidPerformed(address bidder,
                              bytes32 Date_StartTime_Location_bidder_Type,
                              address Caller,
                              uint nonce,
                              uint PaymentAmount,
                              string message);
   
    ///// CONSTRUCTOR ////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
   
    // Set the flexibility contract paramenters.
    constructor (
        bytes32 _Date_StartTime_Location_bidder_Type,
        uint _TotalEnergy,
        uint _PenaltyAmount,
        uint _PaymentAmount,
        address _bidder,
        address _FlexibilityPlatformContractAddress,
        address _DAIContractAddress,
        address _Caller
        )
        public {
       
            Date_StartTime_Location_bidder_Type = _Date_StartTime_Location_bidder_Type;
            TotalEnergy = _TotalEnergy;
            PenaltyAmount = _PenaltyAmount;
            PaymentAmount = _PaymentAmount;
            bidder = _bidder;
            Listing = WhitelistInterface(_FlexibilityPlatformContractAddress);
            token = DAIInterface(_DAIContractAddress);
            Caller = _Caller;
            PaymentCount = _PaymentAmount;
            PenaltyCount = _PenaltyAmount;
            EnergyCount = _TotalEnergy;
    }
   
    ///// MODIFIER ////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////
   
    modifier onlyCaller(address caller) {
       
        require(msg.sender == caller, "You are not authorized to withdraw the penalty");
        _;
    }
   
    modifier timeConstraint() {
       
        require(now >= (TimeOfCreation + WaitingTime), "The time has not yet passed"); // You need to add a timer of 2 days form creation of the contract
        _;
    }
   
    ///// FUNCTIONS ////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////
   
    //The DSO or TSO reuqest the penalty
    function withdrawPenalty() external onlyCaller(msg.sender) timeConstraint() {
       
        token.transfer(msg.sender, PaymentCount + PenaltyCount);
       
        emit PenaltyLost(PenaltyCount, Date_StartTime_Location_bidder_Type, bidder, "The penalty has been withdrawn.");
    }
   
    function PaymentRequest(
        uint256 _energy,
        bytes32 _strData,
        uint256 _nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
        )
        external {
           
            require(PaymentCount > 0, "All the payment has been processed.");
            require(Listing.verifyBidder(msg.sender) == true, "You are not authorized to request this payment.");
           
            // Check signature and read content from the message from the certified SM, it should be in the whitelist
            // This recreates the message hash that was signed by the SM.
            bytes32 hash = keccak256(abi.encodePacked(_energy, _strData, _nonce));

            // Verify that the message's signer is the owner of the signed message
            address signer = ecrecover(hash, v, r, s);

            // We check whether the SM is authorized to provide with
            require(Listing.verifySM(signer) == true, "SM not authorized.");
           
            // Make sure the nonce has not been used before for replay attacks
            require(!seenNonces[signer][_nonce], "The nonce has been already specified.");
            seenNonces[signer][_nonce] = true;
           
            // Check that the content matches the hereby saved contract
            require(_strData == Date_StartTime_Location_bidder_Type, "The contract does not match witht the energy transfer.");
           
            // This is done to ensure that the entire payment is performed, as otherwise providing more energy in the smart contract will throw the transaction
            if (_energy > EnergyCount) {
               
                token.transfer(msg.sender, PenaltyCount + PaymentCount);
                emit PartialBidPerformed(msg.sender, _strData, Caller, _nonce, PaymentCount, "All your bid has been performed.");
                PaymentCount = 0;

            } else {
               
                //We sibtract the energy from the energy count to keep track of how much energy is still needed
                EnergyCount = EnergyCount.sub(_energy);
               
                // Calculate payment
                uint PartialPayment = (PaymentAmount.mul(_energy)).div(TotalEnergy);
                PaymentCount = PaymentCount.sub(PartialPayment);
               
                // Recalculate penalty
                uint PartialPenalty = (PenaltyAmount.mul(_energy)).div(TotalEnergy);
                PenaltyCount = PenaltyCount.sub(PartialPenalty);
               
                // Send payment and part of the penalty. With this there is not need for another function to give back penalties
                token.transfer(msg.sender, PartialPayment + PartialPenalty);
               
                emit PartialBidPerformed(msg.sender, _strData, Caller, _nonce, PartialPayment, "Part of your bid has been performed.");
            }
    }
} 