// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./FundMe.sol";

contract FundTokenERC20 is ERC20{
    FundMe fundMe;//初始化FundMe合约1
    //启用ERC20的结构体
    constructor(address fundMeaddr) ERC20("FundTokenERC20","FT"){
        fundMe = FundMe(fundMeaddr);//初始化FundMe合约2
    }

    function mint(uint256 amountToMint) public{
        require(fundMe.fundersToAmount(msg.sender)>=amountToMint,"you cannot mint this much of token");
        require(fundMe.getFundSuccess(),"The FundMe is not completed yet");
        _mint(msg.sender,amountToMint);//换这么多token进balance里面
        fundMe.setFunderToAmount(msg.sender, fundMe.fundersToAmount(msg.sender)-amountToMint);//eth减去对应数量
    }

    function claim(uint256 amountToClaim) public {//兑换
        require(balanceOf(msg.sender) >= amountToClaim,"You donnot have enought ERC20 tokens.");
        require(fundMe.getFundSuccess(),"The FundMe is not completed yet");
        /*too add nft*/

        //burn 掉tokens
        _burn(msg.sender,amountToClaim);
    }
}
