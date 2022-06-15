import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Token", function () {
  const decimals = 18;
  let sender: SignerWithAddress,
    recipient: SignerWithAddress,
    account: SignerWithAddress,
    accountOther: SignerWithAddress;

  beforeEach(async function () {
    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy("Nikolai", "NIC", decimals);
    await token.deployed();
    [sender, recipient, account, accountOther] = await ethers.getSigners();
    this.token = token;
  });

  it("Мета данные контракта", async function () {
    expect(await this.token.name()).to.equal("Nikolai");
    expect(await this.token.symbol()).to.equal("NIC");
    expect(await this.token.decimals()).to.equal(decimals);
    expect(await this.token.totalSupply()).to.equal(0);
  });

  it("Создание и удаление токенов", async function () {
    expect(await this.token.balanceOf(account.address)).to.equal(0);
    expect(await this.token.balanceOf(accountOther.address)).to.equal(0);
    expect(await this.token.totalSupply()).to.equal(0);

    await this.token.mint(account.address, 20);
    await this.token.mint(accountOther.address, 10);

    expect(await this.token.balanceOf(account.address)).to.equal(20);
    expect(await this.token.balanceOf(accountOther.address)).to.equal(10);
    expect(await this.token.totalSupply()).to.equal(30);

    await this.token.burn(account.address, 5);
    await this.token.burn(accountOther.address, 5);

    expect(await this.token.balanceOf(account.address)).to.equal(15);
    expect(await this.token.balanceOf(accountOther.address)).to.equal(5);
    expect(await this.token.totalSupply()).to.equal(20);

    await expect(
      this.token.mint(ethers.constants.AddressZero, 20)
    ).to.be.revertedWith("ERC20: mint to the zero address");
    await expect(
      this.token.burn(ethers.constants.AddressZero, 5)
    ).to.be.revertedWith("ERC20: burn from the zero address");
    await expect(this.token.burn(account.address, 20)).to.be.revertedWith(
      "ERC20: burn amount exceeds balance"
    );
  });

  it("Апрув токенов", async function () {
    await this.token.approve(recipient.address, 20);
    expect(
      await this.token.allowance(sender.address, recipient.address)
    ).to.equal(20);

    await this.token.approve(recipient.address, 5);
    expect(
      await this.token.allowance(sender.address, recipient.address)
    ).to.equal(5);

    await this.token.increaseAllowance(recipient.address, 5);
    expect(
      await this.token.allowance(sender.address, recipient.address)
    ).to.equal(10);

    await this.token.decreaseAllowance(recipient.address, 3);
    expect(
      await this.token.allowance(sender.address, recipient.address)
    ).to.equal(7);

    await expect(
      this.token.decreaseAllowance(recipient.address, 10)
    ).to.be.revertedWith("ERC20: decreased allowance below zero");
    await expect(
      this.token.increaseAllowance(ethers.constants.AddressZero, 10)
    ).to.be.revertedWith("ERC20: approve to the zero address");
  });

  it("Перевод токенов", async function () {
    await this.token.mint(sender.address, 20);
    await this.token.approve(sender.address, 20);
    await this.token.transfer(recipient.address, 6);

    expect(await this.token.balanceOf(sender.address)).to.equal(14);
    expect(await this.token.balanceOf(recipient.address)).to.equal(6);

    await this.token.connect(recipient).transfer(sender.address, 1);

    expect(await this.token.balanceOf(sender.address)).to.equal(15);
    expect(await this.token.balanceOf(recipient.address)).to.equal(5);

    await this.token.transferFrom(sender.address, recipient.address, 3);
    expect(await this.token.balanceOf(sender.address)).to.equal(12);
    expect(await this.token.balanceOf(recipient.address)).to.equal(8);

    await expect(
      this.token.transferFrom(
        ethers.constants.AddressZero,
        recipient.address,
        10
      )
    ).to.be.revertedWith("ERC20: transfer from the zero address");
    await expect(
      this.token.transferFrom(sender.address, ethers.constants.AddressZero, 10)
    ).to.be.revertedWith("ERC20: transfer to the zero address");
    await expect(
      this.token.transferFrom(sender.address, recipient.address, 15)
    ).to.be.revertedWith("ERC20: transfer amount exceeds balance");

    await this.token.approve(sender.address, 10);
    await expect(
      this.token.transferFrom(sender.address, recipient.address, 11)
    ).to.be.revertedWith("ERC20: transfer amount exceeds allowance");
  });
});
