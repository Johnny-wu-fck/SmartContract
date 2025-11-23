const{DECIMAL,INITIAL_ANSWER} = require("../helper-hardhat-config")

module.exports=async({getNamedAccounts,deployments}) => {//把两个变量直接一开始就放进括号里获取，后面无需定义直接用
    const firstAccount = (await getNamedAccounts()).firstAccount//getNamedAccounts会自动找到config里面的namedAccounts
    const {deploy} = deployments//deployments.deploy
    await deploy("MockV3Aggregator",{
        from:firstAccount,
        args:[DECIMAL,INITIAL_ANSWER],
        log:true
    })
}

module.exports.tags = ["all","mock"]//其他合约拿来部署用的