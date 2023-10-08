// SPDX-License-Identifier: MIT
// Creator: andreitoma8
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "openzeppelin/contracts/token/ERCfo20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "src/interfaces/IWETH.sol";

contract ERC20Stakeable is ERC20 {
    using SafeERC20 for IERC20;
    IERC20 public wethToken;
    struct Staker {
        // The deposited tokens of the Staker
        uint256 deposited;
        // Last time of details update for Deposit
        uint256 timeOfLastUpdate;
        // Calculated, but unclaimed rewards. These are calculated each time
        // a user writes to the contract.
        uint256 unclaimedRewards;
    }

    // Rewards per hour. A fraction calculated as x/10.000.000 to get the percentage
    uint256 public rewardsPerHour = 336; // 0.0014%/h or 25% APR

    // Minimum amount to stake
    uint256 public minStake = 1 ether;

    // Compounding frequency limit in seconds
    uint256 public compoundFreq = 3600; //1 hours

    // Mapping of address to Staker info
    mapping(address => Staker) internal stakers;

    // Constructor function
    constructor()
        ERC20("dayo2013", "Dy")
    {
        wethToken = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    }


    function deposit(uint256 _amount) public  {
        require(_amount >= minStake, "Amount smaller than minimimum deposit");
        require(
            balanceOf(msg.sender) >= _amount,
            "Can't stake more than you own"
        );
        if (stakers[msg.sender].deposited == 0) {
            stakers[msg.sender].deposited = _amount;
            stakers[msg.sender].timeOfLastUpdate = block.timestamp;
            stakers[msg.sender].unclaimedRewards = 0;
        } else {
            uint256 rewards = calculateRewards(msg.sender);
            stakers[msg.sender].unclaimedRewards += rewards;
            stakers[msg.sender].deposited += _amount;
            stakers[msg.sender].timeOfLastUpdate = block.timestamp;
        }
        _burn(msg.sender, _amount);
    }

    // Compound the rewards and reset the last time of update for Deposit info
    function stakeRewards() external{
        require(stakers[msg.sender].deposited > 0, "You have no deposit");
        require(
            compoundRewardsTimer(msg.sender) == 0,
            "Tried to compound rewards too soon"
        );
        uint256 rewards = calculateRewards(msg.sender) +
            stakers[msg.sender].unclaimedRewards;
        stakers[msg.sender].unclaimedRewards = 0;
        stakers[msg.sender].deposited += rewards;
        stakers[msg.sender].timeOfLastUpdate = block.timestamp;
    }

    // Mints rewards for msg.sender
    function claimRewards() external {
        uint256 rewards = calculateRewards(msg.sender) +
            stakers[msg.sender].unclaimedRewards;
        require(rewards > 0, "You have no rewards");
        stakers[msg.sender].unclaimedRewards = 0;
        stakers[msg.sender].timeOfLastUpdate = block.timestamp;
        _mint(msg.sender, rewards);
    }

    // Withdraw specified amount of staked tokens
    function withdraw(uint256 _amount) external {
        require(
            stakers[msg.sender].deposited >= _amount,
            "Can't withdraw more than you have"
        );
        uint256 _rewards = calculateRewards(msg.sender);
        stakers[msg.sender].deposited -= _amount;
        stakers[msg.sender].timeOfLastUpdate = block.timestamp;
        stakers[msg.sender].unclaimedRewards = _rewards;
        _mint(msg.sender, _amount);
    }

    // Withdraw all stake and rewards and mints them to the msg.sender
    function withdrawAll() external {
        require(stakers[msg.sender].deposited > 0, "You have no deposit");
        uint256 _rewards = calculateRewards(msg.sender) +
            stakers[msg.sender].unclaimedRewards;
        uint256 _deposit = stakers[msg.sender].deposited;
        stakers[msg.sender].deposited = 0;
        stakers[msg.sender].timeOfLastUpdate = 0;
        uint256 _amount = _rewards + _deposit;
        _mint(msg.sender, _amount);
    }

    // Function useful for fron-end that returns user stake and rewards by address
    function getDepositInfo(address _user)
        public
        view
        returns (uint256 _stake, uint256 _rewards)
    {
        _stake = stakers[_user].deposited;
        _rewards =
            calculateRewards(_user) +
            stakers[msg.sender].unclaimedRewards;
        return (_stake, _rewards);
    }

    // Utility function that returns the timer for restaking rewards
    function compoundRewardsTimer(address _user)
        public
        view
        returns (uint256 _timer)
    {
        if (stakers[_user].timeOfLastUpdate + compoundFreq <= block.timestamp) {
            return 0;
        } else {
            return
                (stakers[_user].timeOfLastUpdate + compoundFreq) -
                block.timestamp;
        }
    }

    // Calculate the rewards since the last update on Deposit info
    function calculateRewards(address _staker)
        internal
        view
        returns (uint256 rewards)
    {
        return (((((block.timestamp - stakers[_staker].timeOfLastUpdate) *
            stakers[_staker].deposited) * rewardsPerHour) / 3600) / 10000000);
    }
}