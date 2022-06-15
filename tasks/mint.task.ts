/* eslint node/no-unpublished-import: "off", curly: "error" */
import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";

task("mint", "Mint tokens to account.")
  .addParam("address", "Smart-contract address.")
  .addParam("account", "The account's address.")
  .addParam("amount", "The amount of token.")
  .setAction(async ({ address, account, amount }, { ethers }) => {
    const Contract = await ethers.getContractFactory("Token");
    const contract = Contract.attach(address);
    console.info("Contract address: ", address);

    await contract.mint(account, amount);

    const totalSupply = await contract.totalSupply();
    const balance = await contract.balanceOf(account);
    console.log("Tokens total supply : ", totalSupply.toString());
    console.log("Tokens on the account: ", balance.toString());
  });

module.exports = {};
