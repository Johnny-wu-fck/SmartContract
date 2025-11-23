const { assert } = require("chai")
const { ethers, getNamedAccounts } = require("hardhat")

describe("test fundme contract",async function(){
    let fundMe//声明合约和账户
    let firstAccount
    beforeEach(async function(){
        deployments.fixture(["all"])//fixture来部署所有带all的合约
        firstAccount = (await getNamedAccounts()).firstAccount
        const fundMeDeployment = await deployments.get("FundMe")
        fundMe = ethers.getContractAt("FundMe",fundMeDeployment.address)
    })
    it("test if the owner is msg.sender",async function(){//测试构造函数
        // const [firstAccount] = await ethers.getSigners()//获取发送交易的人，知道是谁发送的，现在这个firstaccount不是config里面那个是获取的输入的变量
        // const fundMeFactory = await ethers.getContractFactory("FundMe")//导入(合约名)里的合约
        // const fundMe = await fundMeFactory.deploy(100)//部署，后面是构造函数的入参，默认第一个发送的人
        await fundMe.waitForDeployment()//等待部署成功
        assert.equal((await fundMe.owner()),firstAccount)
    })
    it("test if the datafeed is correct",async function(){//测试构造函数
        // const fundMeFactory = await ethers.getContractFactory("FundMe")//导入合约
        // const fundMe = await fundMeFactory.deploy(100)//部署
        await fundMe.waitForDeployment()//等待部署成功
        assert.equal((await fundMe.dataFeed()),0x694AA1769357215DE4FAC081bf1f309aDC325306)
    })
})