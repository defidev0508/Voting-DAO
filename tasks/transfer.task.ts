/* eslint node/no-unpublished-import: "off", curly: "error" */
import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";

task("transfer", "Transfer tokens from account.")
  .addParam("address", "Smart-contract address.")
  .addParam("recipient", "The recipient's address")
  .addParam("amount", "The amount of token")
  .setAction(async ({ address, recipient, amount }, { ethers }) => {
    const Contract = await ethers.getContractFactory("Token");
    const contract = Contract.attach(address);

    await contract.transfer(recipient, amount);
  });

module.exports = {};
