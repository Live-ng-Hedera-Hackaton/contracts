// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Pool.sol";



contract LoanPoolFactory {
    address[] public loanPools;

    event LoanPoolCreated(address indexed loanPool, address indexed creator);

    function createLoanPool(
        uint256 goalAmount,
        uint256 interestRate,
        uint256 loanPeriod,
        string memory name,
        address token
    ) external {
        LoanPool newLoanPool = new LoanPool(
            goalAmount,
            interestRate,
            loanPeriod,
            name,
            token
        );
        loanPools.push(address(newLoanPool));
        emit LoanPoolCreated(address(newLoanPool), msg.sender);
    }

    function getLoanPools() external view returns (address[] memory) {
        return loanPools;
    }
}
