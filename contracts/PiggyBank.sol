// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;
contract PiggyBank{
   
   //amount of cash which can be withdrawed any time 
   uint256 public cash;
   //amount of deposited amount which only can be withdrawd after a period of time
   uint256 public depositAmount;

  //dt of deposited amount can be withdrawed
   uint256 public unfreezeTime;

   //bank owner
   address owner;

   //deposited amount freezed seconds, 1 minutes for tutorial purpose
   uint256 constant freezeTime = 1 minutes;

  
   constructor(){
     owner=msg.sender;
     unfreezeTime= block.timestamp+ freezeTime;
   }
 
   //deposit method  require eth >0
   function deposit() payable  external{
       require(msg.value>0,"need send eth");
       uint256 amount=msg.value;
       uint256 splitAmount=amount/2;

       cash+=splitAmount;
       depositAmount+=splitAmount;


   }

   //withraw cash method 
   function withdrawCash(uint256 amount) external{
       require(owner==msg.sender,"is not owner");
        cash-=amount;
        payable(msg.sender).transfer(amount);


   }

   //withraw deposited amount method 
   function withdrawDeposit(uint256 amount) external {
       require(owner==msg.sender,"is not owner");
       require(block.timestamp>unfreezeTime,"time is not ready");
       depositAmount-=amount;
       payable(msg.sender).transfer(amount);

   }
  
   //utils to show timestamp
   function currentDt() external  view returns (uint256){
     return block.timestamp;
   }

}