// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;
contract MyPiggyBank {
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // check DepositRatio range (0-100)
    modifier checkDepositRatio(uint256 _depositRatio) {
        _depositRatio = _depositRatio / (10 ** 18);
        require(
            _depositRatio >= 0 || _depositRatio <= 100,
            "depositRatio must be between 0 and 100 "
        );
        _;
    }

    modifier sendMoreEth() {
        require(msg.value > 0, "need send eth");
        _;
    }

    modifier checkwithraw() {
        require(!withdrawStatus, " withdraw not finish please wait ");
        _;
    }

    //amount of cash which can be withdrawed any time
    uint256 public cash;

    //bank owner
    address owner;

    struct depositReceipt {
        uint256 depositTime;
        uint256 depositAmount;
    }

    mapping(uint256 => depositReceipt) public depositReceipts;

    uint256 public depositTimes = 0;

    uint256 public totalAmount;

    //deposited amount freezed seconds, 1 minutes for tutorial purpose
    uint256 constant freezeTime = 1 minutes;

    uint256 public depositRatio;

    bool withdrawStatus = false;
    constructor() {
        owner = msg.sender;
    }

    function modifyDepositRatio(
        uint256 _depositRatio
    ) external checkDepositRatio(_depositRatio) onlyOwner {
        depositRatio = _depositRatio;
    }

    //deposit method  require eth >0
    function deposit() external payable sendMoreEth {
        uint256 _depositTime = block.timestamp + freezeTime;
        uint256 _depoistAmount;
        if (depositRatio == 0) {
            _depoistAmount = 0;
        } else {
            _depoistAmount = (msg.value * depositRatio) / 100;
            depositReceipts[depositTimes] = depositReceipt(
                _depositTime,
                _depoistAmount
            );
            depositTimes++;
        }
        cash += msg.value - _depoistAmount;
    }

    //withraw cash method
    function withdrawCash(uint256 amount) external onlyOwner {
        require(cash >= amount, "not enough cash ");
        cash -= amount;
        payable(msg.sender).transfer(amount);
    }

    //withraw deposited amount method
    function withdrawDeposit(uint256 amount) external onlyOwner checkwithraw {
        withdrawStatus = true;
        uint256 timeStamp = getBlockTime();
        totalAmount = availableAmount(timeStamp);
        require(totalAmount > amount, " not have engouht amount to withdraw ");
        payable(msg.sender).transfer(amount);
        totalAmount -= amount;
        for (uint256 i = 0; i < depositTimes; i++) {
            uint256 _depositAmount = depositReceipts[i].depositAmount;
            if (_depositAmount <= amount) {
                depositReceipts[i].depositAmount = 0;
                amount -= _depositAmount;
            } else {
                depositReceipts[i].depositAmount -= amount;
                withdrawStatus = false;
                break;
            }
        }
    }

    function availableAmount(
        uint256 timeStamp
    ) public view returns (uint256 amount) {
        if (timeStamp == 0) {
            timeStamp = block.timestamp;
        }
        for (uint256 i = 0; i < depositTimes; i++) {
            uint256 _depositTime = depositReceipts[i].depositTime;
            if (_depositTime <= timeStamp) {
                amount += depositReceipts[i].depositAmount;
            }
        }
    }

    function getBlockTime() public view returns (uint256) {
        return block.timestamp;
    }
}
