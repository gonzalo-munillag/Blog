///////////////////////////////
// Gonzalo Munilla Garrido
// 27/06/2019
// Title: Auction ENS names
// Web3 Version: web3@1.0.0-beta.35
// This code is used to interact with a smart contract, which I have developed, deployed in the Rinkeby test-chain. The smart contract itslef holds an auction for the names uploaded to the smart contract by the contract owner.
// One may use this piece of code to set names, bid, insert a new token address to which the auction smart contract is linked, get the cost of a specific name or finish an auction. Setting a name for an auction, setting the address of the toen contract
// and finish an auction can only be performed by the contract owner. Thus in order for you to test it, I would deploy the smart contract anew and then test all the functionalities.
// Things to change: public and private key, directory of the json file,
///////////////////////////////

const Web3 = require('web3');
const Tx = require('ethereumjs-tx');
var fs = require("fs");

// The connection to the mainnet works both with infura or cloudflare
// LOCAL NODE
// const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8101"));
// CLOUDFARE
// const web3 = new Web3(new Web3.providers.HttpProvider("https://cloudflare-eth.com"));
// INFURA
const web3 = new Web3(new Web3.providers.HttpProvider("https://rinkeby.infura.io/v3/93a4253479fb4b22bdae749e3604f740"));

///////////////////////////////
// Constants /////////////////
////////////////////////////

// Insert your keys here
const publicKey = "Insert your public key";
const privateKey = new Buffer.from("Insert your privateKey key", 'hex');

///////////////////////////////
// Contract and variable definitions //////
////////////////////////////

// Variable to get the cost from. This way you do not need to change the name in every function for testing
var name = "Input a name of your choice";
var cost = 100;

// MAINnet //////
////////////////////////////

// We save the contract ABI in a variable
const Auctionabi = [{"constant":false,"inputs":[{"name":"amount","type":"uint256"},{"name":"name","type":"string"}],"name":"Bid","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":false,"inputs":[{"name":"name","type":"string"},{"name":"cost","type":"uint256"}],"name":"setName","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":false,"inputs":[],"name":"renounceOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":true,"inputs":[],"name":"isOwner","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":true,"inputs":[{"name":"name","type":"string"}],"name":"getCost","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":false,"inputs":[{"name":"ContractAddress","type":"address"}],"name":"setTokenContractAddress","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":false,"inputs":[{"name":"name","type":"string"}],"name":"finishAuction","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"anonymous":false,"inputs":[{"indexed":false,"name":"name","type":"string"},{"indexed":false,"name":"cost","type":"uint256"},
{"indexed":false,"name":"text","type":"string"}],"name":"NewName","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"name","type":"string"},{"indexed":false,"name":"bid","type":"uint256"},
{"indexed":false,"name":"TimeRemaining","type":"uint256"},{"indexed":false,"name":"text","type":"string"}],"name":"NewBid","type":"event"},
{"anonymous":false,"inputs":[{"indexed":true,"name":"previousOwner","type":"address"},{"indexed":true,"name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"}];

// We save teh contract address in a variable
const AuctionAdrress = "0x68fed8994b76d42c9fafa70baac1367184bb166a";

// We create the contract pointer
const AuctionContract = new web3.eth.Contract(Auctionabi, AuctionAdrress);

// We save the contract ABI in a variable. We do not use this token in this code, but perhaps for future work it is convinient to have it.
const Tokenabi = [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":false,"inputs":[],"name":"acquireDAI","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},
{"constant":false,"inputs":[{"name":"spender","type":"address"},
{"name":"value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"to","type":"address"},
{"name":"value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":false,"inputs":[{"name":"_amount","type":"uint256"}],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":false,"inputs":[{"name":"spender","type":"address"},
{"name":"addedValue","type":"uint256"}],"name":"increaseAllowance","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_value","type":"uint256"}],"name":"mint","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":true,"inputs":[{"name":"owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":false,"inputs":[],"name":"renounceOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":true,"inputs":[],"name":"isOwner","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"spender","type":"address"},
{"name":"subtractedValue","type":"uint256"}],"name":"decreaseAllowance","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":false,"inputs":[{"name":"to","type":"address"},
{"name":"value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":true,"inputs":[{"name":"owner","type":"address"},
{"name":"spender","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":true,"inputs":[],"name":"getEtherBalance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":true,"inputs":[],"name":"getDecimals","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"inputs":[{"name":"_value","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},
{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},
{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"previousOwner","type":"address"},
{"indexed":true,"name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"}];

// We save teh contract address in a variable
const TokenAdrress = "0x602450b7bbaa725f118609e62bea79590b9634b6";

// We create the contract pointer
const TokenContract = new web3.eth.Contract(Tokenabi, TokenAdrress);

// This variables are used to keep track of the last block in which we read the events, in this case Name and bid.
// We define this variables globally as promises create new objects in parallel and thus it would be impossible to track the previous blocks
var PreviousBlockNumberName;
var PreviousBlockNumberBid;

///////////////////////////////
// Function definitions //////
////////////////////////////

//////////////////////////////////////////////////////////
// FUNCTION 1: This function listens continuosly using the GetEvents function
async function Listening()
{
  //Create a json object for storing event data
  var json = {"NewName":[], "NewBid":[]};

  // This variable conatains the block number where the events were read for the last time. We keep track of this number so as not to read the same events twice. We initialize them with the number of a block which will not be mined again and it is far i nthe past
  PreviousBlockNumberName = 0;
  PreviousBlockNumberBid = 0;

  while(true) {

    // Read the newest events and save it in a json object
    json = await GetEvents(json)

    //Save data into a json file
    CreateJSON(json)
  }
}

// FUNCTION 1.1: This function is used to listen to the latest events. This function is constructted to be used in an infitie loop
async function GetEvents(json) {

  // The event listeners are hereby executed
  AuctionContract.getPastEvents(
    'NewName',
    {
      toBlock: 'latest'
    },
      (error, event) => {
                          // This is done just in case the array is empty, which would lead th an error and also it will not go in again if we listen to the same block as where we last read the events
                          if (typeof event[0] != "undefined" && event[0] != null && event[0].blockNumber != PreviousBlockNumberName)
                          {
                            // We save the blocknumber so as not to read it again
                            PreviousBlockNumberName = event[0].blockNumber;

                            // We go thorugh all this type of events within the block and save it in an object
                            for(var i = 0; i < event.length; i++)
                            {
                              NewName = {
                                "name": event[i].returnValues["name"],
                                "cost": event[i].returnValues["cost"]
                            };

                            // We save the object in yet another object
                            json.NewName[json.NewName.length] = NewName;
                            console.log("NEW NAME");
                            console.log(NewName);
                            console.log();
                            }
                         }
                         else {
                             console.log("No new name.")
                         }
                        }
 );

 await AuctionContract.getPastEvents(
   'NewBid',
   {
     toBlock: 'latest'
   },
     (error, event) => {
                           // This is done just in case the array is empty, which would lead th an error
                           if (typeof event[0] != "undefined" && event[0] != null && event[0].blockNumber != PreviousBlockNumberBid)
                           {
                             PreviousBlockNumberBid = event[0].blockNumber;
                             for(var i = 0; i < event.length; i++)
                             {
                               NewBid = {
                                 "name": event[i].returnValues["name"],
                                 "bid": event[i].returnValues["bid"],
                                 "TimeRemaining": event[i].returnValues["TimeRemaining"]
                             };
                             json.NewBid[json.NewBid.length] = NewBid;
                             console.log("NEW BID");
                             console.log(NewBid);
                             console.log();
                               }
                          }
                          else {
                              console.log("No new bid.")
                          }
                       }
);

 return json;
}

// FUNCTION 1.2: Create json file from a json object and save it
function CreateJSON(json) {

  var data = JSON.stringify(json);
  // One must change this directoty address!!!
  fs.writeFile('C:/Users/GONZALO/Desktop/Slock.it/Rinkeby_Data.json', data, function(err) {
      if(err)
      {
          return console.log(err);
      }
  });
}


//////////////////////////////////////////////////////////
// FUNCTION 2: This function is used to read all the contents from the ENS event json file and set them for an auction. As these transactions would be sent in parallel due to the asyncronic nature of the used functions, we have
// separated this function from the canon function 4 for sending and signing transaction because otherwise the function transactionCount does not provide its value on time for the other function to send the transacton with a correct nonce.
async function ReadJSONandSetNames() {

  let TxCount = await web3.eth.getTransactionCount(publicKey);

  // One must change this directoty address!!!
  fs.readFile('C:/Users/GONZALO/Desktop/Slock.it/MainNet_Data.json', 'utf8', (err, jsonString) => {
      if (err) {
          console.log("File read failed:", err);
          return
      }
      try {
         const NameRegistered = JSON.parse(jsonString);

         for (i = 0; i < NameRegistered.NameRegistered.length; i++) {

           // In each iteration we will set a name

           let tx_builder = AuctionContract.methods.setName(NameRegistered.NameRegistered[i].name, NameRegistered.NameRegistered[i].cost);

           let encoded_tx = tx_builder.encodeABI();

           let  rawTx  = {
               gasLimit: web3.utils.toHex(200000),
               gasPrice:  web3.utils.toHex(web3.utils.toWei("1", "gwei")),
               nonce: TxCount,
               data: encoded_tx,
               from: publicKey,
               to: AuctionAdrress
           };

           // We create the transaction object with the previous information
           let tx = new Tx(rawTx);

           tx.sign(privateKey);
           let serializedTx = tx.serialize();

           web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex'))
           .on('receipt', console.log);

           TxCount += 1;
         }
      }
      catch(err) {
         console.log('Error parsing JSON string:', err);
      }
  })
}

//////////////////////////////////////////////////////////
// CALL functions
//////////////////////////////////////////////////////////

// FUNCTION 3: It is used for getting the highest bid number for a specific name
async function getCost(name) {
  await  AuctionContract.methods.getCost(name).call({ from: publicKey})
      .then(result => {
          console.log("Highest bid for " + name + " is: " + JSON.stringify(result));
      })
      .catch(() => {
          console.log("Failed to collect output.");
      });
}

//////////////////////////////////////////////////////////
// SEND functions
//////////////////////////////////////////////////////////

// FUNCTION 4: Sign and send transaction, common for all functions
async function signAndsendTx(tx_builder, ContractAdrress) {

  // We get the last transaction number of the account
  let _nonce = await web3.eth.getTransactionCount(publicKey);

  // We build the raw transaction. The gas amount is enough for all the transactions of the contract
  let encoded_tx = tx_builder.encodeABI();
  let  rawTx  = {
      gasLimit: web3.utils.toHex(200000),
      gasPrice:  web3.utils.toHex(web3.utils.toWei("1", "gwei")),
      nonce: _nonce,
      data: encoded_tx,
      from: publicKey,
      to: ContractAdrress
  };

  // We create the transaction object with the previous information
  let tx = new Tx(rawTx);

  tx.sign(privateKey);
  let serializedTx = tx.serialize();

  await web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex'))
  .on('receipt', console.log);

}

// FUNCTION 4.1: Function to set a new name ofr an auction. Onlyowner
async function setName(name, cost) {

  // We encode the input of the function
  let tx_builder = AuctionContract.methods.setName(name, cost);
  signAndsendTx(tx_builder, AuctionAdrress);
}

// FUNCTION 4.2: Function to set a new address for the token contrat to which the auction contract is linked to. Onlyowner
async function setTokenContractAddress(contractAddress) {

  // We encode the input of the function
  let tx_builder = AuctionContract.methods.setTokenContractAddress(contractAddress);
  signAndsendTx(tx_builder, AuctionAdrress);
}

// FUNCTION 4.3: Function used to bid for a name
async function Bid(amount, name) {

  // We encode the input of the function
  let tx_builder = AuctionContract.methods.Bid(amount, name);
  signAndsendTx(tx_builder, AuctionAdrress);
}

// FUNCTION 4.4: Function used to finish the auction of a name. Onlyowner
async function finishAuction(name) {

  // We encode the input of the function
  let tx_builder = AuctionContract.methods.finishAuction(name);
  signAndsendTx(tx_builder, AuctionAdrress);
}

////////////////////////////
// MAIN////////////////////
/////////////////////////
// @Tester:  Uncomment the function to use them. I recommended to execute the contract in one terminal with Listening() while in another you set names and bid for those names. That way you can see the events being read

// EVENTS //////////////////////////////////////////////////

// To keep saving the latest events as they are triggered, we use this functions
// Listening();


// CALLS //////////////////////////////////////////////////

// Get the cost of a Name
// getCost(name);


// SEND //////////////////////////////////////////////////

// It is done only once, or as many times as the token contract changes, Onlyowner
// setTokenContractAddress(TokenAdrress);

// Auction, Set all the names from the ENS service for an auction, Onlyowner
// ReadJSONandSetNames();

// Set one name, Onlyowner
// setName(name, cost);

// Bid for a name
// Bid(10000000000, name);

// Finish the auction, Onlyowner
// finishAuction(name);
