const {
  Client,
  PrivateKey,
  AccountCreateTransaction,
  AccountBalanceQuery,
  Hbar,
  ContractCreateTransaction,
  ContractFunctionParameters
} = require('@hashgraph/sdk')
require('dotenv').config()
async function readContract() {
  // Grab your Hedera testnet account ID and private key from your .env file
  const myAccountId = process.env.MY_ACCOUNT_ID
  const myPrivateKey = process.env.MY_PRIVATE_KEY

  // If we weren't able to grab it, we should throw a new error
  if (myAccountId == null || myPrivateKey == null) {
    throw new Error(
      'Environment variables myAccountId and myPrivateKey must be present',
    )
  }

  // Create your connection to the Hedera Network
  const client = Client
  .forTestnet()
   .setOperator(myAccountId, myPrivateKey)

// Calls a function of the smart contract
const contractQuery = await new ContractCallQuery()
    
     //Set the contract ID to return the request for
     .setContractId(newContractId)
     //Set the contract function to call
     .setFunction("get_message" )
     //Set the query payment for the node returning the request
     //This value must cover the cost of the request otherwise will fail
     .setQueryPayment(new Hbar(2))
      //Set the gas for the query
      .setGas(100000);

//Submit to a Hedera network
const getMessage = await contractQuery.execute(client);

// Get a string from the result at index 0
const message = getMessage.getString(0);

//Log the message
console.log("The contract message: " + message);

}


readContract() 

