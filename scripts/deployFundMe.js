const { Contract } = require("ethers")
const {ethers} = require("hardhat")//从库里拿函数用
// import hre from "hardhat";
// import { verifyContract } from "@nomicfoundation/hardhat-verify/verify";

async function main(){
    //creat factory
    const fundMeFactory = await  ethers.getContractFactory("FundMe")//导入合约
    console.log("deploying...")
    //deploy contract from factory
    const fundMe = await fundMeFactory.deploy(100)//部署合约,传入FundMe构造函数的入参
    await fundMe.waitForDeployment()//等合约部署入块
    console.log("successfully!!! contract address:" + fundMe.target);//target是合约地址

    //verify FundME
    if(hre.network.config.chainId == 11155111 && process.env.ETHERSCAN_API_KEY){
      console.log("waiting for 2 block..." );
      await fundMe.deploymentTransaction().wait(2)//等待部署完过五个区块再验证，否则容易验证失败
      await verifyFundME(fundMe.target,100)//验证时间10s
    } else {
      console.log("skip verify")
    }
    //初始化两个账户
    const [firstAccount, secondAccount] = await ethers.getSigners()//getSigner可以找到配置文件里写的两个账户给到前面赋值
    //fund contract with first account
    const fundTx = await fundMe.fund({value: ethers.parseEther("0.05")})//用fund合约转那么多fund进去先默认选择第一个账户
    await fundTx.wait()//等fund完成
    //chenck balance of account
    const balanceOfContract = await ethers.provider.getBalance(fundMe.target)
    console.log(`balance of the contract is ${balanceOfContract}`)
    //fund contract with second account
    const fundTxWithSecondAccount = await fundMe.connect(secondAccount).fund({value: ethers.parseEther("0.05")})
    await fundTxWithSecondAccount.wait()
    //check balance again
    const balanceOfContractAfterSecondFund = await ethers.provider.getBalance(fundMe.target)
    console.log(`balance of the contract is ${balanceOfContractAfterSecondFund}`)
    //check mapping
    const firstAccountbalanceInFundMe = await fundMe.fundersToAmount(firstAccount.address)
    const secondAccountbalanceInFundMe = await fundMe.fundersToAmount(firstAccount.address)
    console.log(`Balance of first account ${firstAccount.address} is ${firstAccountbalanceInFundMe}`)
    console.log(`Balance of second account ${secondAccount.address} is ${secondAccountbalanceInFundMe}`)


}

async function verifyFundME(address, lockTime) {
    console.log("Verifying contract on Etherscan...");
    try {
        await run("verify:verify", {
            address: address,
            constructorArguments: [lockTime],
        });
        console.log(`Successfully verified! Address: ${address}`);
    } catch (e) {
        if (e.message.includes("Already Verified")) {
            console.log("Already verified!");
        } else {
            console.error("Verification failed:", e.message);
        }
    }
}


main().then().catch((error) => {//表示函数要执行，不加括号就是表示只是用来当作变量
    console.error(error)//把打印错误出来
    process.exit(1)//1表示非正常退出
})
