// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BaseFlowEscrow is ReentrancyGuard {
    enum Status { Created, Funded, Released, Refunded, Disputed }

    address public client;
    address public provider;
    address public arbitrator;
    address public feeReceiver;

    uint256 public amount;
    uint256 public fee; // basis points
    uint256 public deadline;
    Status public status;

    modifier onlyClient() {
        require(msg.sender == client, "Not client");
        _;
    }

    modifier onlyArbitrator() {
        require(msg.sender == arbitrator, "Not arbitrator");
        _;
    }

    constructor(
        address _client,
        address _provider,
        address _arbitrator,
        address _feeReceiver,
        uint256 _fee,
        uint256 _deadline
    ) {
        client = _client;
        provider = _provider;
        arbitrator = _arbitrator;
        feeReceiver = _feeReceiver;
        fee = _fee;
        deadline = _deadline;
        status = Status.Created;
    }

    function fund() external payable onlyClient {
        require(status == Status.Created, "Invalid state");
        amount = msg.value;
        status = Status.Funded;
    }

    function release() external onlyClient nonReentrant {
        require(status == Status.Funded, "Invalid state");
        status = Status.Released;

        uint256 feeAmount = (amount * fee) / 10_000;
        payable(feeReceiver).transfer(feeAmount);
        payable(provider).transfer(amount - feeAmount);
    }

    function dispute() external {
        require(msg.sender == client || msg.sender == provider, "Unauthorized");
        require(status == Status.Funded, "Invalid state");
        status = Status.Disputed;
    }

    function refundClient() external onlyArbitrator nonReentrant {
        require(status == Status.Disputed, "Not disputed");
        status = Status.Refunded;
        payable(client).transfer(amount);
    }

    function autoRelease() external nonReentrant {
        require(block.timestamp > deadline, "Deadline not passed");
        require(status == Status.Funded, "Invalid state");
        status = Status.Released;
        payable(provider).transfer(amount);
    }
}
