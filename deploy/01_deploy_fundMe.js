// function deployFunction() {
//     console.log("a deploy function")
// }

// module.exports.default=deployFunction//默认导出后面这个函数

// module.exports=async(hre) => {//匿名函数，功能就等于上面的函数，无需命名
//     const getNamedAccounts = hre.getNameAccounts
//     const deployments = hre.deployments
//     console.log("a deploy function")
// }

//该代码用于快捷部署链用

//getnameaccounts可以直接去config配置文件里面找account
module.exports=async({getNamedAccounts,deployments}) => {//把两个变量直接一开始就放进括号里获取，后面无需定义直接用
    const firstAccount = (await getNamedAccounts()).firstAccount//getNamedAccounts会自动找到config里面的namedAccounts
    const {deploy} = deployments//deployments.deploy
    await deploy("FundMe",{
        from:firstAccount,
        args:[100],
        log:true
    })
}

module.exports.tags = ["all","fundme"]//其他合约拿来部署用的