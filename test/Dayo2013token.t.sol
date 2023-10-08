// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {ERC20Stakeable} from "../src/Dayo2013token.sol";
import {IERC20} from "../src/IERC20.sol";

contract stakeTest is Test {
    // uint256 minStake = 1 ether;
     ERC20Stakeable stake;

    //function setUp()
    function setUp()public {
        stake = new ERC20Stakeable();
    }
    function testminstake ()public{
        uint256 _amount = 1 ether;
        vm.expectRevert("Amount smaller than minimimum deposit");
        stake.deposit(0.5 ether);
    }
    function testbalanceof()public{
        uint256 _amount = 1 ether;
        vm.expectRevert("Can't stake more than you own");
        stake.deposit(_amount);
    }
    function teststakerdeposit()public{
        uint256 _amount = 1 ether;
        vm.expectRevert("You have no deposit");
        stake.stakeRewards();
        
    }
    // function testcomparewards()public{
    //     uint256 _amount = 1 ether;
    //     vm.expectRevert("Tried to compound rewards too soon");
    //     stake.stakeRewards();
    // }
    function testclaimrewards()public{
        uint256 _amount = 1 ether;
        vm.expectRevert("You have no rewards");
        stake.claimRewards();
    }
    function testwithdraw()public{
        uint256 _amount = 1 ether;
        vm.expectRevert("You have no deposit");
        stake.withdrawAll();
    }
    // function testcomparedRewardTimer()public{
    //     uint256 _amount = 1 ether;
    //     vm.expectRevert("Tried to compound rewards too soon");
    //     address _user = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    //     stake.compoundRewardsTimer(_user);
    // }
}



