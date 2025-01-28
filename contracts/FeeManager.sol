// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FeeManager {
    uint256 public platformFeePercentage = 2; // 2%
    address public feeRecipient;

    event FeesUpdated(uint256 newPercentage);
    event FeesWithdrawn(uint256 amount);

    constructor(address _feeRecipient) {
        feeRecipient = _feeRecipient;
    }

    function calculateFee(uint256 amount) public view returns (uint256) {
        return (amount * platformFeePercentage) / 100;
    }

    function updateFeePercentage(uint256 newPercentage) external {
        require(msg.sender == feeRecipient, "Unauthorized");
        require(newPercentage <= 10, "Fee too high");
        platformFeePercentage = newPercentage;
        emit FeesUpdated(newPercentage);
    }
}