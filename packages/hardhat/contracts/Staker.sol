pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping (address => uint256) public balances;
  uint256 public constant threshold = 0.01 ether;
  bool public openForWithdraw = false;
  uint256 public deadline = 0;

  event Stake (
    address staker,
    uint256 balance
  );


  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    deadline = now + 100 seconds;
  }

  modifier beforeDeadline() {
    require(now < deadline, "Must go before the deadline");
    _;
  }

  modifier atOrAfterDeadline() {
    require(now >= deadline, "Wait longer! The deadline hasn't been reached yet.");
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
  // Message sender withdraws all of their funds to an address that does not have to be msg.sender.
  function withdraw(address payable _to) public notCompleted {
    require(openForWithdraw, "Contract is not yet open for withdrawal.");
    require(balances[msg.sender] > 0, "You have no balance.");
    // We do not require that msg.sender == _to address.
    (bool sent, bytes memory data) = _to.call{value: balances[msg.sender]}("");
    require(sent, "Failed to send Ether");
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    // Time left only updates once a new block is mined; now == block.timestamp
    if (now >= deadline) {
      return 0;
    }
    return deadline - now;
  }

}
