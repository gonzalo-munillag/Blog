pragma solidity >=0.4.21 <0.7.0;

import "./Ownable.sol";
import "./ERC20.sol";

// ----------------------------------------------------------------------------

// ERC Token Standard #20 

// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

// ----------------------------------------------------------------------------

/// @title A token for bidding in an Auction
/// @author Gonzalo Munilla Garrido
/// @notice The contract possess all the functionalities of an ERC20. It has all the functionalities and it is used as currency to bid on the Auction Smart Contract

contract TokenSlockit is Ownable, ERC20 {
    
    
    //// VARIABLES //////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    
    string public symbol;

    string public  name;
    
    uint decimals;

    //// FUNCTIONS //////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    
    constructor(uint _value) public {

        symbol = "SLC";

        name = "TokenSlockit";
        
        decimals = 18;
        
        _mint( msg.sender, _value * 10**uint(decimals));
    }
    
    // To mint further tokens
    function mint(address _from, uint256 _value) public onlyOwner {
        
        _mint( _from, _value * 10**uint(decimals));
    }
    
    function withdraw(uint _amount) public onlyOwner {
        
        uint amount = _amount;
        require(amount  <= address(this).balance);
         address payable _owner = address(uint160(owner())); // We had to change the type of address to payable in ownable contract but also here with uint160 in order to convert it
        _owner.transfer(amount);
    }
    
    function acquireToken() public payable{
        
        require(msg.value != 0);
        
        // We do not use decimals here becuase the msg.sender will send wei
        uint value = msg.value.div(2);
        
        require(value <= balanceOf(owner()), "Not enough supply.");
        
        _transfer(owner(), msg.sender, value);
    }
    
    function getEtherBalance() view public returns(uint) {
        
        return address(this).balance;
    }
    
    function getDecimals() view public returns(uint) {
        
        return decimals;
    }
}

