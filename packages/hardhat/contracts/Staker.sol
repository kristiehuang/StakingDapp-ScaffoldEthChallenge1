pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping (address => uint256) public balances;
  uint256 public constant threshold = 0.05 ether;
  bool public openForWithdraw = false;
  uint256 public deadline = 0;

  event Stake(
    address indexed staker,
    uint256 balance
  );


  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    deadline = block.timestamp + 1 days;
  }

  modifier beforeDeadline() {
    require(block.timestamp < deadline, "Must go before the deadline");
    _;
  }

  modifier atOrAfterDeadline() {
    require(block.timestamp >= deadline, "Wait longer! The deadline hasn't been reached yet.");
    _;
  }

  modifier notCompleted() {
    require(!(exampleExternalContract.completed()), "This stake has already been executed.");
    _;

  }


  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable beforeDeadline notCompleted {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public atOrAfterDeadline notCompleted {
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }
  }


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  // Message sender withdraws all of their funds to themselves.
  function withdraw() public notCompleted {
    require(openForWithdraw, "Contract is not yet open for withdrawal.");
    require(balances[msg.sender] > 0, "You have no balance.");
    (bool sent, bytes memory data) = msg.sender.call{value: balances[msg.sender]}("");
    require(sent, "Failed to send Ether");
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    // Time left only updates once a new block is mined; now == block.timestamp
    if (block.timestamp >= deadline) {
      return 0;
    }
    return deadline - block.timestamp;
  }

}
