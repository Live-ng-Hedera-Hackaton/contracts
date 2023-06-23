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
 async function deployContract() {
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
  
   // Instantiate the contract instance
const contractTx = await new ContractCreateTransaction()
//Set the file ID of the Hedera file storing the bytecode
.setBytecodeFileId("0.0.14968864")
//Set the gas to instantiate the contract
.setGas(100000)
//Provide the constructor parameters for the contract
.setConstructorParameters(new ContractFunctionParameters().addString("Hello from Hedera!"));

//Submit the transaction to the Hedera test network
const contractResponse = await contractTx.execute(client);

//Get the receipt of the file create transaction
const contractReceipt = await contractResponse.getReceipt(client);

//Get the smart contract ID
const newContractId = contractReceipt.contractId;

//Log the smart contract ID
console.log("The smart contract ID is " + newContractId);

//v2 JavaScript SDK

  }


  deployContract() 

  