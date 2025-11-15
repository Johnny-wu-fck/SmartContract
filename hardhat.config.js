require("@nomicfoundation/hardhat-toolbox");
+ require("@nomicfoundation/hardhat-verify");
require("@chainlink/env-enc").config()
require("./tasks")//不用把index写出来，如果没写会自动去找这

const SEPOLIA_URL = process.env.SEPOLIA_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY
const PRIVATE_KEY_1 = process.env.PRIVATE_KEY_1
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks:{
    sepolia:{
      url:SEPOLIA_URL,
      accounts:[PRIVATE_KEY, PRIVATE_KEY_1],
      chainId:11155111//识别是否为sepolia测试网，在chainlist.org里面找
    }
  },
  etherscan:{//用hardhat验证合约是否部署
    apiKey:ETHERSCAN_API_KEY
    
  }
};
