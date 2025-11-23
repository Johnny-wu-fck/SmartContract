const { task } = require("hardhat/config")

task("deploy-fundme").setAction(async(taskArgs, hre) => {
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
        await fundMe.deploymentTransaction().wait(3)//等待部署完过五个区块再验证，否则容易验证失败
        await verifyFundME(fundMe.target,100)//验证时间10s
    } else {
        console.log("skip verify")
    }
} )//async(入参, 环境)

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

module.exports = {}//导出task