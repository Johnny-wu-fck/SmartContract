const { task } = require("hardhat/config")

task("interact-fundme")
    .addParam("addr","fundme contract address").//fundme合约里面构造函数的入参
    setAction(async(taskArgs, hre) =>{
        const fundMeFactory = await ethers.getContractFactory("FundMe")//导入合约，新建fundme这个合约对象
        const fundMe = fundMeFactory.attach(taskArgs.addr)

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
    
})