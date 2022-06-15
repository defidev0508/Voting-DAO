import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";

describe("DAO", function () {
  const decimals = 18;
  let chairPerson: SignerWithAddress, token: Contract, dao: Contract;

  this.beforeEach(async function () {
    [chairPerson] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("Token");
    token = await Token.deploy("Nikolai", "NIC", decimals);
    await token.deployed();

    const DAO = await ethers.getContractFactory("DAO");
    dao = await DAO.deploy(chairPerson.address, token.address, 10, 259200);
    await dao.deployed();

    await token.mint(chairPerson.address, 1000);
  });

  it("Init DAO", async function () {
    [chairPerson] = await ethers.getSigners();
    const DAO = await ethers.getContractFactory("DAO");

    // TODO: Как проверить что все хорошо?
    // await expect(DAO.deploy(chairPerson.address, token.address, 20, 1)).to.be.not;

    await expect(
      DAO.deploy(chairPerson.address, token.address, 0, 0)
    ).to.be.revertedWith("DAO: MinimumQuorum should be more: 10");

    await expect(
      DAO.deploy(chairPerson.address, token.address, 10, 0)
    ).to.be.revertedWith("DAO: Period duration should be more: 259200");

    await expect(
      DAO.deploy(ethers.constants.AddressZero, token.address, 10, 259200)
    ).to.be.revertedWith("DAO: Chairperson from the zero address.");

    await expect(
      DAO.deploy(chairPerson.address, ethers.constants.AddressZero, 10, 259200)
    ).to.be.revertedWith("DAO: Token from the zero address.");
  });

  it("Deposit", async function () {
    expect(await token.balanceOf(chairPerson.address)).to.equal(1000);
    expect(await dao.balanceOf(chairPerson.address)).to.equal(0);
    await token.approve(dao.address, 100);
    expect(await dao.deposit(100))
      .to.emit(dao, "Deposit")
      .withArgs(chairPerson.address, 100);
    expect(await token.balanceOf(chairPerson.address)).to.equal(900);
    expect(await dao.balanceOf(chairPerson.address)).to.equal(100);
  });

  it("Withdraw", async function () {
    await expect(dao.withdraw(1000)).to.be.revertedWith(
      "DAO: transfer amount exceeds vote balance."
    );
    await token.approve(dao.address, 100);
    await dao.deposit(100);
    expect(await dao.balanceOf(chairPerson.address)).to.equal(100);

    // QUESTION: В Чем ошибка?
    // await token
    //   .connect(await ethers.getSigner(dao.address))
    //   .approve(chairPerson.address, 100);
    // await dao.withdraw(100);

    // expect(await dao.withdraw(100))
    //   .to.emit(dao, "Withdraw")
    //   .withArgs(chairPerson.address, 100);

    // TODO: Добавить проверку на активные голосования

    // expect(await dao.balanceOf(chairPerson.address)).to.equal(900);
    // await dao.withdraw(900);
    // expect(await dao.balanceOf(chairPerson.address)).to.equal(0);
    // await expect(dao.withdraw(1)).to.be.revertedWith(
    //   "DAO: transfer amount exceeds vote balance."
    // );
  });

  // it("Create Proposal", async function () {
  //   await this.contract.deposit(1000);

  //   // await expect(this.contract.withdraw(1000)).to.be.revertedWith(
  //   //   "DAO: transfer amount exceeds vote balance"
  //   // );
  //   await expect(
  //     this.contract.createProposal("Test", "Test", ethers.constants.AddressZero, , 10)
  //   ).to.be.revertedWith("DAO: transfer from the zero address");

  //   // string memory _description,
  //   // address _recipient,
  //   // bytes32 _byteCode,
  //   // uint8 _minimumQuorum

  //   await this.contract.createProposal("Test");
  //   expect(await this.contract.voteBalanceOf(this.sender.address)).to.equal(
  //     1000
  //   );
  //   await this.contract.withdraw(100);
  //   expect(await this.contract.voteBalanceOf(this.sender.address)).to.equal(
  //     900
  //   );

  //   // TODO: Добавить тест на активные голосования
  // });
});
