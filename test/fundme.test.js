const { assert } = require("chai")
const { ethers } = require("hardhat")

describe("test fundme contract",async function(){
    it("test if the owner is msg.sender",async function(){//测试构造函数
        const [firstAccount] = await ethers.getSigners()//获取发送交易的人
        const fundMeFactory = await ethers.getContractFactory("FundMe")//导入合约
        const fundMe = await fundMeFactory.deploy(100)//部署
        await fundMe.waitForDeployment()//等待部署成功
        assert.equal((await fundMe.owner()),firstAccount.address)
    })
    it("test if the datafeed is correct",async function(){//测试构造函数
        const [firstAccount] = await ethers.getSigners()//获取发送交易的人
        const fundMeFactory = await ethers.getContractFactory("FundMe")//导入合约
        const fundMe = await fundMeFactory.deploy(100)//部署
        await fundMe.waitForDeployment()//等待部署成功
        assert.equal((await fundMe.dataFeed()),0x694AA1769357215DE4FAC081bf1f309aDC325306)
    })
})