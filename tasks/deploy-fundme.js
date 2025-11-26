// tasks/deploy-fundme.js  用于单独部署 MultiCryptoPriceFeed
const { task } = require("hardhat/config");
require("dotenv").config();

task("deploy-fundme", "单独部署 + 验证 MultiCryptoPriceFeed（价格预言机）")
  .setAction(async (taskArgs, hre) => {
    const { ethers, network } = hre;
    const isSepolia = network.config.chainId === 11155111;
    const hasKey = !!process.env.ETHERSCAN_API_KEY;

    console.log("正在单独部署 MultiCryptoPriceFeed 到", network.name);

    // 部署 MultiCryptoPriceFeed（无构造函数参数）
    const PriceFeedFactory = await ethers.getContractFactory("MultiCryptoPriceFeed");
    console.log("Deploying MultiCryptoPriceFeed...");
    const priceFeed = await PriceFeedFactory.deploy();

    await priceFeed.waitForDeployment();
    const address = await priceFeed.getAddress();
    console.log(`MultiCryptoPriceFeed 部署成功: ${address}`);

    // Sepolia 自动验证
    if (isSepolia && hasKey) {
      console.log("等待 5 个区块后自动验证...");
      await priceFeed.deploymentTransaction()?.wait(5);

      try {
        await hre.run("verify:verify", {
          address: address,
          constructorArguments: [],  // 无参数
        });
        console.log("Etherscan 验证成功");
      } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
          console.log("已验证过");
        } else {
          console.warn("验证失败（可手动补）：", e.message.split("\n")[0]);
        }
      }
    } else {
      console.log("跳过验证（非 Sepolia 或无 Etherscan Key）");
    }

    console.log("\n部署完成！合约地址：");
    console.log(address);
  });

module.exports = {};






// // tasks/deploy-fundme.js   ← 直接覆盖你原来的文件就行
// const { task } = require("hardhat/config");
// require("dotenv").config();

// task("deploy-fundme", "Deploys Marketplace NFT marketplace and verifies on Etherscan")
//   .setAction(async (taskArgs, hre) => {
//     console.log("Deploying Marketplace contract...");

//     // 直接部署，Marketplace 构造函数无参数
//     const MarketplaceFactory = await hre.ethers.getContractFactory("Marketplace");
//     const marketplace = await MarketplaceFactory.deploy();

//     await marketplace.waitForDeployment();
//     const address = await marketplace.getAddress();
//     console.log(`Marketplace deployed to: ${address}`);

//     // Sepolia 自动验证 → 构造函数无参数，所以传空数组 []
//     if (hre.network.config.chainId === 11155111 && process.env.ETHERSCAN_API_KEY) {
//       console.log("Waiting for 5 blocks before verification...");
//       await marketplace.deploymentTransaction()?.wait(5);

//       await verify(address, []);  // 关键：无参数传 []
//     } else {
//       console.log("Skipping verification (not on Sepolia or no Etherscan API key)");
//     }
//   });

// // 复用的验证函数（保持不变）
// async function verify(address, constructorArgs) {
//   console.log("Verifying Marketplace on Etherscan...");
//   try {
//     await hre.run("verify:verify", {
//       address: address,
//       constructorArguments: constructorArgs,  // [] 表示无构造函数参数
//     });
//     console.log("Verification successful!");
//   } catch (e) {
//     if (e.message.toLowerCase().includes("already verified")) {
//       console.log("Already verified!");
//     } else {
//       console.error("Verification failed:", e.message);
//     }
//   }
// }

// module.exports = {};




// // tasks/deploy-fundme.js   （你想继续叫这个名字就继续叫，功能改成部署 AvatarNFT）
// const { task } = require("hardhat/config");
// require("dotenv").config();

// task("deploy-fundme", "Deploys AvatarNFT and verifies on Etherscan")
//   .setAction(async (taskArgs, hre) => {
//     console.log("Deploying AvatarNFT...");

//     // 直接部署，无构造函数参数
//     const AvatarNFTFactory = await hre.ethers.getContractFactory("AvatarNFT");
//     const avatarNFT = await AvatarNFTFactory.deploy();

//     await avatarNFT.waitForDeployment();
//     const address = await avatarNFT.getAddress();
//     console.log(`AvatarNFT deployed to: ${address}`);

//     // Sepolia 自动验证（构造函数参数为空数组 []）
//     if (hre.network.config.chainId === 11155111 && process.env.ETHERSCAN_API_KEY) {
//       console.log("Waiting for 5 blocks before verification...");
//       await avatarNFT.deploymentTransaction()?.wait(5);

//       await verify(address, []);  // 关键：无参构造函数传空数组
//     } else {
//       console.log("Skipping verification (not on Sepolia or no API key)");
//     }
//   });

// // 复用的验证函数
// async function verify(address, constructorArgs) {
//   console.log("Verifying AvatarNFT on Etherscan...");
//   try {
//     await hre.run("verify:verify", {
//       address: address,
//       constructorArguments: constructorArgs, // [] 代表无参数
//     });
//     console.log("Verification successful!");
//   } catch (e) {
//     if (e.message.toLowerCase().includes("already verified")) {
//       console.log("Already verified!");
//     } else {
//       console.error("Verification failed:", e.message);
//     }
//   }
// }

// module.exports = {};




// const { task } = require("hardhat/config");
// require("dotenv").config();

// task("deploy-fundme", "Deploys FundTokenERC20 (linked to existing FundMe)")
//   .setAction(async (taskArgs, hre) => {
//     // 写死你的 FundMe 地址
//     const FUND_ME_ADDRESS = "0xA2464A2EC7589A19Cb31dF950bD07b1FE979D0FF";

//     try {
//       // 部署 FundTokenERC20
//       const FundTokenFactory = await hre.ethers.getContractFactory("FundTokenERC20");
//       console.log("Deploying FundTokenERC20...");
//       const fundToken = await FundTokenFactory.deploy(FUND_ME_ADDRESS);

//       await fundToken.waitForDeployment();
//       const tokenAddress = await fundToken.getAddress();
//       console.log(`FundTokenERC20 deployed to: ${tokenAddress}`);

//       // Sepolia 自动验证
//       if (hre.network.config.chainId === 11155111 && process.env.ETHERSCAN_API_KEY) {
//         console.log("Waiting for 5 blocks before verification...");
//         await fundToken.deploymentTransaction()?.wait(5);

//         await verify(tokenAddress, [FUND_ME_ADDRESS]); // 只传一个 address 参数
//       } else {
//         console.log("Skipping verification (not on Sepolia or no Etherscan API key)");
//       }
//     } catch (error) {
//       console.error("Deployment failed:", error.message);
//     }
//   });

// async function verify(address, args) {
//   console.log("Verifying contract on Etherscan...");
//   try {
//     await hre.run("verify:verify", {
//       address: address,
//       constructorArguments: args,  // [address]，不是 [100]
//     });
//     console.log("Verification successful!");
//   } catch (e) {
//     if (e.message.toLowerCase().includes("already verified")) {
//       console.log("Already verified!");
//     } else {
//       console.error("Verification failed:", e.message);
//     }
//   }
// }

// module.exports = {};



// const { task } = require("hardhat/config")

// task("deploy-fundme").setAction(async(taskArgs, hre) => {
//     //creat factory
//     const fundMeFactory = await  ethers.getContractFactory("FundMe")//导入合约
//     console.log("deploying...")
//      //deploy contract from factory
//     const fundMe = await fundMeFactory.deploy(100)//部署合约,传入FundMe构造函数的入参
//     await fundMe.waitForDeployment()//等合约部署入块
//     console.log("successfully!!! contract address:" + fundMe.target);//target是合约地址
    
//     //verify FundME
//     if(hre.network.config.chainId == 11155111 && process.env.ETHERSCAN_API_KEY){
//         console.log("waiting for 2 block..." );
//         await fundMe.deploymentTransaction().wait(3)//等待部署完过五个区块再验证，否则容易验证失败
//         await verifyFundME(fundMe.target,100)//验证时间10s
//     } else {
//         console.log("skip verify")
//     }
// } )//async(入参, 环境)

// async function verifyFundME(address, lockTime) {
//     console.log("Verifying contract on Etherscan...");
//     try {
//         await run("verify:verify", {
//             address: address,
//             constructorArguments: [lockTime],
//         });
//         console.log(`Successfully verified! Address: ${address}`);
//     } catch (e) {
//         if (e.message.includes("Already Verified")) {
//             console.log("Already verified!");
//         } else {
//             console.error("Verification failed:", e.message);
//         }
//     }
// }

// module.exports = {}//导出task


