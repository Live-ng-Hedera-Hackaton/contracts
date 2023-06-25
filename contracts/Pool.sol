// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract LoanPool {
    struct Pool {
        address creator;
        uint256 goalAmount;
        uint256 interestRate;
        string name;
        uint256 id;
        uint256 loanPeriod;
        uint256 totalContributions;
        uint256 startDate;
        uint256 endDate;
        mapping(address => uint256) contributions;
        mapping(address => bool) hasContributed;
        bool isOpen;
        bool isRepaid;
    }

    Pool public pool;
    IERC20 public HUSDX;
    event ContributionAdded(
        address indexed poolAddress,
        address indexed contributor,
        uint256 amount
    );
    event LoanRepaid(address indexed poolAddress);
    event Borrowed(
        address indexed poolAddress,
        address indexed borrower,
        uint256 amount
    );
    modifier onlyPoolCreator() {
        require(
            msg.sender == pool.creator,
            "Only the pool creator can perform this action"
        );
        _;
    }

    modifier onlyPoolContributor() {
        require(
            pool.hasContributed[msg.sender],
            "Only pool contributors can perform this action"
        );
        _;
    }

    constructor(
        uint256 goalAmount,
        uint256 interestRate,
        uint256 loanPeriod,
        string memory _name,
        address token
    ) {
        HUSDX = IERC20(token);
        require(goalAmount > 0, "Goal amount must be greater than zero");
        require(interestRate > 0, "Interest rate must be greater than zero");
        require(loanPeriod > 0, "Loan period must be greater than zero");

        pool.creator = msg.sender;
        pool.goalAmount = goalAmount;
        pool.name = _name;
        pool.startDate = block.timestamp;
        pool.endDate = block.timestamp + loanPeriod;
        pool.interestRate = interestRate;
        pool.loanPeriod = loanPeriod;
        pool.isOpen = true;
    }

    function contribute(uint256 amt) external payable {
        require(pool.isOpen, "The pool is not open for contributions");
        require(!pool.isRepaid, "The loan has already been repaid");
        pool.contributions[msg.sender] += amt;
        pool.totalContributions += amt;
        pool.hasContributed[msg.sender] = true;
        require(
            HUSDX.transferFrom(msg.sender, address(this), amt),
            "Transfer failed"
        );
        emit ContributionAdded(address(this), msg.sender, msg.value);
    }

    function repayLoan(uint256 amt, address contractID)
        external
        payable
        onlyPoolCreator
    {
        require(pool.isOpen, "The pool is not open");
        require(contractID == address(this), "The pool is not open");
        require(!pool.isRepaid, "The loan has already been repaid");
        pool.isRepaid = true;
        require(
            HUSDX.allowance(msg.sender, address(this)) >= amt,
            "HUSDX allowance is too low"
        );
        HUSDX.transferFrom(msg.sender, address(this), amt);
        emit LoanRepaid(address(this));
    }

    function poolBalance() public view returns (uint256) {
        return HUSDX.balanceOf(address(this));
    }

    function borrowLoan(uint256 amount) external {
        require(pool.isOpen, "The pool is not open for borrowing");
        require(!pool.isRepaid, "The loan has already been repaid");
        require(
            amount <= pool.goalAmount,
            "Borrowed amount exceeds the loan goal"
        );

        require(
            pool.hasContributed[msg.sender],
            "Only pool contributors can borrow the loan"
        );

        HUSDX.transfer(msg.sender, amount);

        emit Borrowed(address(this), msg.sender, amount);
    }
}
