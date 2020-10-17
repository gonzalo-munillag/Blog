///////////////////////////////
// Gonzalo Munilla Garrido
// 01/07/2019
// Title: ENS Event Listner
// Web3 Version: web3@1.0.0-beta.35
// This code is used to listen to events in the main ethereum network. The main purpose of this  code is to listen to the evnts of X days prior to the time of execution, save the data in a json file for later use and print the events on the console.
// The locatin of the json file, where it is written, must be changed to a directory of your own computer. Line 120
// The connection to the mainnet works both with infura or cloudflare
///////////////////////////////

const Web3 = require('web3');
var fs = require("fs");

//LOCAL NODE
// const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8101"));
//CLOUDFARE
// const web3 = new Web3(new Web3.providers.HttpProvider("https://cloudflare-eth.com"));
//INFURA
const web3 = new Web3(new Web3.providers.HttpProvider("https://mainnet.infura.io/v3/93a4253479fb4b22bdae749e3604f740"));

///////////////////////////////
// Constants /////////////////
////////////////////////////

// The multiplication of these two constants will provide the starting block ("from block") from which we would like to listen to
const days = 1;
const NumberBlocksDay = 5760;

///////////////////////////////
// Contract definitions //////
////////////////////////////

// We save the minified contract ABI in a variable
const ENSabi = [{"constant":true,"inputs":[{"name":"interfaceID","type":"bytes4"}],"name":"supportsInterface","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"pure","type":"function"},
{"constant":false,"inputs":[],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":false,"inputs":[{"name":"_prices","type":"address"}],"name":"setPriceOracle","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":false,"inputs":[],"name":"renounceOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_minCommitmentAge","type":"uint256"},
{"name":"_maxCommitmentAge","type":"uint256"}],"name":"setCommitmentAges","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":true,"inputs":[{"name":"","type":"bytes32"}],"name":"commitments","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":true,"inputs":[{"name":"name","type":"string"},{"name":"duration","type":"uint256"}],"name":"rentPrice","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":false,"inputs":[{"name":"name","type":"string"},{"name":"owner","type":"address"},{"name":"duration","type":"uint256"},
{"name":"secret","type":"bytes32"}],"name":"register","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},
{"constant":true,"inputs":[],"name":"MIN_REGISTRATION_DURATION","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":true,"inputs":[],"name":"minCommitmentAge","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":true,"inputs":[],"name":"isOwner","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":true,"inputs":[{"name":"name","type":"string"}],"name":"valid","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":false,"inputs":[{"name":"name","type":"string"},{"name":"duration","type":"uint256"}],"name":"renew","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},
{"constant":true,"inputs":[{"name":"name","type":"string"}],"name":"available","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":true,"inputs":[],"name":"maxCommitmentAge","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},
{"constant":false,"inputs":[{"name":"commitment","type":"bytes32"}],"name":"commit","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},
{"constant":true,"inputs":[{"name":"name","type":"string"},{"name":"owner","type":"address"},
{"name":"secret","type":"bytes32"}],"name":"makeCommitment","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"pure","type":"function"},{"inputs":[{"name":"_base","type":"address"},
{"name":"_prices","type":"address"},{"name":"_minCommitmentAge","type":"uint256"},{"name":"_maxCommitmentAge","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},
{"anonymous":false,"inputs":[{"indexed":false,"name":"name","type":"string"},{"indexed":true,"name":"label","type":"bytes32"},{"indexed":true,"name":"owner","type":"address"},
{"indexed":false,"name":"cost","type":"uint256"},{"indexed":false,"name":"expires","type":"uint256"}],"name":"NameRegistered","type":"event"},
{"anonymous":false,"inputs":[{"indexed":false,"name":"name","type":"string"},{"indexed":true,"name":"label","type":"bytes32"},
{"indexed":false,"name":"cost","type":"uint256"},{"indexed":false,"name":"expires","type":"uint256"}],"name":"NameRenewed","type":"event"},
{"anonymous":false,"inputs":[{"indexed":true,"name":"oracle","type":"address"}],"name":"NewPriceOracle","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"previousOwner","type":"address"},
{"indexed":true,"name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"}];

// We save teh contract address in a variable
const ENSAdrress = "0xF0AD5cAd05e10572EfcEB849f6Ff0c68f9700455";

// We create the contract pointer
const ENSContract = new web3.eth.Contract(ENSabi, ENSAdrress);

///////////////////////////////
// Function definitions //////
////////////////////////////

//////////////////////////////////////////////////////////
// This function listens at once to a set of events and saves the result in a json file
async function Listen(NumberPastBlocks) {

  //Create a json object for storing event data
  var json = {"NameRegistered":[]};

  // Get latest block number
  var BlockNumber = await web3.eth.getBlockNumber();
  console.log("Latest block number: " + BlockNumber)

  //Read events
  await ENSContract.getPastEvents(
    'NameRegistered',
    {
      fromBlock: BlockNumber - NumberPastBlocks,
      toBlock: 'latest'
    },
      (error, event) => {
                          if (typeof event[0] != "undefined" && event[0] != null)
                            {
                            for(var i = 0; i < event.length; i++)
                            {
                              NameRegistered = {
                                "name": event[i].returnValues["name"],
                                "label": event[i].returnValues["label"],
                                "owner": event[i].returnValues["owner"],
                                "cost": event[i].returnValues["cost"],
                                "expires": event[i].returnValues["expires"]
                            };
                            json.NameRegistered[json.NameRegistered.length] = NameRegistered;
                            console.log("NEW NAME");
                            console.log(NameRegistered);
                            console.log();
                            }
                         }
                         else
                         {
                           console.log("No new name registered.");
                         }
                        }
 );

 //Save data into a json file
 var data = JSON.stringify(json);

 // This directory location must be changed to one of your choosing in your machine!!!
 fs.writeFile('C:/Users/GONZALO/Desktop/Slock.it/MainNet_Data.json', data, function(err) {
     if(err)
     {
         return console.log(err);
     }
     console.log("The file was saved!");
 });
}

////////////////////////////
// MAIN////////////////////
/////////////////////////

// // Listen to all the events from X days before
Listen(days * NumberBlocksDay);
