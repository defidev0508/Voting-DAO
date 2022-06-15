/* eslint node/no-unpublished-import: "off", curly: "error" */
import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";

task(
  "approve",
  "Sets 'amount' as the allowance of 'spender' over the caller's tokens"
)
  .addParam("address", "Smart-contract address.")
  .addParam("spender", "The spender's address")
  .addParam("amount", "The amount of token")
  .setAction(async ({ address, spender, amount }, { ethers }) => {
    const Contract = await ethers.getContractFactory("Token");
    const contract = Contract.attach(address);

    await contract.approve(spender, amount);
  });

module.exports = {};
