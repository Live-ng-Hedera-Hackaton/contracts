// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LoanPool {
    struct Pool {
        address creator;
        uint goalAmount;
        uint interestRate;
        uint totalContributions;
        mapping(address => uint) contributions;
        mapping(address => bool) hasContributed;
        bool isOpen;
        bool isRepaid;
    }

    mapping(address => Pool) public pools;

    event PoolCreated(address indexed poolAddress, address indexed creator);
    event ContributionAdded(address indexed poolAddress, address indexed contributor, uint amount);
    event LoanRepaid(address indexed poolAddress);
    event FundDisbursed(address indexed poolAddress, address indexed receiver, uint amount);

    modifier onlyPoolCreator(address poolAddress) {
        require(msg.sender == pools[poolAddress].creator, "Only the pool creator can perform this action");
        _;
    }

    modifier onlyPoolContributor(address poolAddress) {
        require(pools[poolAddress].hasContributed[msg.sender], "Only pool contributors can perform this action");
        _;
    }

    function createPool(uint goalAmount, uint interestRate) external {
        require(goalAmount > 0, "Goal amount must be greater than zero");
        require(interestRate > 0, "Interest rate must be greater than zero");

        Pool storage pool = pools[msg.sender];
        require(!pool.isOpen, "You already have an open pool");

        pool.creator = msg.sender;
        pool.goalAmount = goalAmount;
        pool.interestRate = interestRate;
        pool.isOpen = true;

        emit PoolCreated(msg.sender, msg.sender);
    }

    function contribute(address poolAddress) external payable {
        Pool storage pool = pools[poolAddress];
        require(pool.isOpen, "The pool is not open for contributions");
        require(!pool.isRepaid, "The loan has already been repaid");

        pool.contributions[msg.sender] += msg.value;
        pool.totalContributions += msg.value;
        pool.hasContributed[msg.sender] = true;

        emit ContributionAdded(poolAddress, msg.sender, msg.value);
    }

    function repayLoan(address poolAddress) external payable onlyPoolCreator(poolAddress) {
        Pool storage pool = pools[poolAddress];
        require(pool.isOpen, "The pool is not open");
        require(!pool.isRepaid, "The loan has already been repaid");
        require(msg.value >= pool.goalAmount, "You must repay the full loan amount");

        pool.isRepaid = true;
        emit LoanRepaid(poolAddress);
    }

    function disburseFunds(address poolAddress) external onlyPoolCreator(poolAddress) {
        Pool storage pool = pools[poolAddress];
        require(pool.isOpen, "The pool is not open");
        require(pool.isRepaid, "The loan has not been repaid");

        uint totalContributions = pool.totalContributions;
        uint repaidAmount = address(this).balance;

        for (uint i = 0; i < totalContributions; i++) {
            address contributor = address(uint160(uint(poolAddress) + i));
            uint contribution = pool.contributions[contributor];
            uint amountToDisburse = (contribution * repaidAmount) / pool.goalAmount;

            if (amountToDisburse > 0) {
                payable(contributor).transfer(amountToDisburse);
                emit FundDisbursed(poolAddress, contributor, amountToDisburse);
            }
        }
    }

    function getPoolDetails(address poolAddress) external view returns (
        address creator,
        uint goalAmount,
        uint interestRate,
        uint totalContributions,
        bool isOpen,
        bool isRepaid
    ) {
        Pool storage pool = pools[poolAddress];
        return (
            pool.creator,
            pool.goalAmount,
            pool.interestRate,
            pool.totalContributions,
            pool.isOpen,
            pool.isRepaid
        );
    }
}