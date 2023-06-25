const { ethers } = require("hardhat");

module.exports = async () => {
  //Assign the first signer, which comes from the first privateKey from our configuration in hardhat.config.js, to a wallet variable.
  let wallet = (await ethers.getSigners())[0];

  //Initialize a contract factory object
  //name of contract as first parameter
  //wallet/signer used for signing the contract calls/transactions with this contract
  const PoolFactory = await ethers.getContractFactory("LoanPoolFactory", wallet);
  //Using already intilized contract facotry object with our contract, we can invoke deploy function to deploy the contract.
  //Accepts constructor parameters from our contract
  const poolFactory = await PoolFactory.deploy();
  //We use wait to recieve the transaction (deployment) receipt, which contains contractAddress
  const contractAddress = (await poolFactory.deployTransaction.wait())
    .contractAddress;

  console.log(`Greeter deployed to: ${contractAddress}`);

  return contractAddress;
};