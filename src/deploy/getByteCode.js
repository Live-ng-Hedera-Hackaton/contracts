const {
  Client,
  PrivateKey,
  AccountCreateTransaction,
  AccountBalanceQuery,
  Hbar,
  FileCreateTransaction,
  ContractCreateTransaction,
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
  const client = Client.forTestnet()
  client.setOperator(myAccountId.toString(), myPrivateKey.toString())
//Import the compiled contract from the HelloHedera.json file
let helloHedera = require("./HelloHedera.json");
const bytecode = helloHedera.data.bytecode.object;

//Create a file on Hedera and store the hex-encoded bytecode
const fileCreateTx = new FileCreateTransaction()
        //Set the bytecode of the contract
        .setContents(bytecode);

//Submit the file to the Hedera test network signing with the transaction fee payer key specified with the client
const submitTx = await fileCreateTx.execute(client);

//Get the receipt of the file create transaction
const fileReceipt = await submitTx.getReceipt(client);

//Get the file ID from the receipt
const bytecodeFileId = fileReceipt.fileId;

//Log the file ID
console.log("The smart contract byte code file ID is " +bytecodeFileId)
}

deployContract()
