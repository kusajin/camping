// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;
contract MyPiggyBank {
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier checkDepositRatio(uint256 _depositRatio) {
        _depositRatio = _depositRatio/(10**18);
        require(
            _depositRatio >= 0 || _depositRatio <= 100,
            "depositRatio must be between 0 and 100 "
        );
        _;
    }

    modifier checkDeposit() {
        require(!isDeposit, " you can't ");
        _;
    }

    modifier sendMoreEth() {
        require(msg.value > 0, "need send eth");
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

    depositReceipt[] private depositReceiptInfo;

    //deposited amount freezed seconds, 1 minutes for tutorial purpose
    uint256 constant freezeTime = 1 minutes;

    uint256 public depositRatio;

    bool isDeposit = false;

    constructor() {
        owner = msg.sender;
    }

    function updateDepositRatio(
        uint256 _depositRatio
    ) external checkDepositRatio(_depositRatio) checkDeposit onlyOwner {
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
            depositReceiptInfo.push(
                depositReceipt(_depositTime, _depoistAmount)
            ); 
        }
        uint256 splitAmount = msg.value - _depoistAmount;
        cash += splitAmount;
        isDeposit=true;
    }

    //withraw cash method
    function withdrawCash(uint256 amount) external onlyOwner {
        require(cash >= amount, "not enough cash ");
        cash -= amount;
        payable(msg.sender).transfer(amount);
    }

    //withraw deposited amount method
    function withdrawDeposit(uint256 amount) external onlyOwner {
        (uint[] memory _index, uint256 amounts) = getDepistInfo();
        require(
            _index.length > 0 && amounts >= amount,
            " not have engouht amount to withdraw "
        );
        payable(msg.sender).transfer(amount);
        for (uint i = 0; i < _index.length; i++) {
            uint256 _depositAmount = depositReceiptInfo[_index[i]]
                .depositAmount;
            if (_depositAmount <= amount) {
                depositReceiptInfo[_index[i]].depositAmount = 0;
                amount -= _depositAmount;
            } else {
                depositReceiptInfo[_index[i]].depositAmount =
                    amount - _depositAmount;
                amount = 0;
            }
        }
    }

    function getDepistInfo()
        internal
        view
        returns (uint[] memory _index, uint256 amount)
    {
        uint j = 0;
        for (uint256 i = 0; i < depositReceiptInfo.length; i++) {
            if (depositReceiptInfo[i].depositTime <= block.timestamp) {
                _index[j] = i;
                amount += depositReceiptInfo[i].depositAmount;
                j++;
            }
        }
    }
}
