// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe{
    mapping(address=>uint256) public fundersToAmount;//账户-投资钱数

    uint256 MINIMUM_VALUE = 100 * 10 ** 18;//最低转入100美元

    AggregatorV3Interface public dataFeed;

    uint256 constant TARGET = 100 * 10 ** 18;//值达到100美元才可提取

    address public owner;//合同部署者

    uint256 deploymentTimestamp;//开始时间
    uint256 lockTime;//结束时间

    address erc20Addr;

    bool public getFundSuccess = false;

    constructor(uint256 _lockTime){//创建时调用
        owner = msg.sender;
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        deploymentTimestamp = block.timestamp;//开始的时间
        lockTime = _lockTime;//s
    }

    function transferOwnership(address newOwner) public onlyOwner{
        owner = newOwner;
    }

    function fund() external payable {
        require(convertEthToUsd(msg.value) >= MINIMUM_VALUE, "You need to spend more ETH!");
        require(block.timestamp < deploymentTimestamp + lockTime,"window is close");
        fundersToAmount[msg.sender] = msg.value;
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (int256) {//预言机
    // prettier-ignore
    (
      /* uint80 roundId */
      ,
      int256 answer,
      /*uint256 startedAt*/
      ,
      /*uint256 updatedAt*/
      ,
      /*uint80 answeredInRound*/
    ) = dataFeed.latestRoundData();
    return answer;//取当前eth对应美元值
  }
  function convertEthToUsd(uint256 ethAmount)internal view returns(uint256){//返回eth对应的usd
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());//对应美元赋值
        return ethAmount * ethPrice/ (10**8);
        //ETH / USD precision = 10 ** 8
        //X / ETH precision = 10 ** 18,所以要除回个10**8来让位数一样 
  }

  function getFund() external windowClosed onlyOwner{//提款
    require(convertEthToUsd(address(this).balance) >= TARGET,"Target is not reached");//转换有的eth为多少美元
    
    //transfer：transfer ETH and revert if tx failed
    //payable(msg.sender).transfer(address(this).balance);
    //send:transfer ETH and return false if failed
    //bool success = payable(msg.sender).send(address(this).balance);//addr.send(value)
    //require(success,"tx failed");
    //call:transfer ETH with data return value of fuction and bool
    //addr.call("data")
    bool success;
    (success , ) = payable(msg.sender).call{value:address(this).balance}("");
    require(success,"transfer tx failed");//要求success是真才执行
    fundersToAmount[msg.sender] = 0;
    getFundSuccess = true;

  }

  function refund() external windowClosed{
    require(convertEthToUsd(address(this).balance) < TARGET,"Target is reached");
    require(fundersToAmount[msg.sender] != 0, "thiere is no fund for you");   
    bool success;
    (success , ) = payable(msg.sender).call{value:fundersToAmount[msg.sender]}("");
    require(success,"transfer tx failed");
    fundersToAmount[msg.sender] = 0;
  }

  function setFunderToAmount(address funder,uint256 amountToUpdate) external {
    require(msg.sender == erc20Addr,"you do not have permission");//只能erc20的合同能用，要等于这个合约的地址
    fundersToAmount[funder] = amountToUpdate;
  }

  function setErc20Addr(address _erc20Addr) public onlyOwner{//提取erc20合约地址
    erc20Addr = _erc20Addr;
  }

  modifier windowClosed(){
    require(block.timestamp >= deploymentTimestamp + lockTime,"window is not close");
    _;//放语句后面表示先执行语句再执行函数后面的
  }

  modifier onlyOwner(){
    require(msg.sender == owner,"Only owner can transfer ownership");
    _;
  }

}
