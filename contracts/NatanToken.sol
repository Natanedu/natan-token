pragma solidity ^0.4.23;

import "./MintableToken.sol";
import "./NatanConstant.sol";

contract natanEduToken is natanEduConstant, MintableToken {
    // variable to lock the transfers
    bool public canTransfer = false;

    // Accounts who can transfer token even if transfer is locked while sale is on.
    mapping(address => bool) adrAllowedForTransfer;

     // Sale Start Time
    uint256 public saleStartTime;

    //storage Withdraw Count
    uint256 public storageWithdrawCount = 0;

    address validOwner;

    //Events required to emit
    event ColdWalletWithdraw(address _from, address _to, uint256 _amount);
    event TransferAddressAdded(address indexed _address);
    event TransferAddressRemoved(address indexed _address);

    constructor() public {
        validOwner = msg.sender;
    }

    modifier onlyAllowedForTransfer {
        if(!canTransfer) {
            require(adrAllowedForTransfer[msg.sender] == true);
            _;
        } else {
            _;
        }
    }

    modifier onlyValidOwner {
        require(msg.sender == owner || msg.sender == validOwner);
        _;
    }

    function name() public pure returns (string _name) {
        return TOKEN_NAME;
    }

    function symbol() public pure returns (string _symbol) {
        return TOKEN_SYMBOL;
    }

    function decimals() public pure returns (uint256 _decimals) {
        return TOKEN_DECIMALS;
    }

    function addExcluded(address _address) external onlyValidOwner {
        adrAllowedForTransfer[_address] = true;
        emit TransferAddressAdded(_address);
    }

    function removeFromExcluded(address _address) external onlyValidOwner {
        require(adrAllowedForTransfer[_address] = true, "Not exist in list of excluded!");
        adrAllowedForTransfer[_address] = false;
        emit TransferAddressRemoved(_address);
    }

    function transferFrom(address _from, address _to, uint256 _value) onlyAllowedForTransfer public returns (bool) {
        require(_from != COLD_WALLET, "can not transfer tokens from storage wallet!");
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) onlyAllowedForTransfer public returns (bool) {
        require(msg.sender != COLD_WALLET, "can not transfer tokens from storage wallet!");
        return super.transfer(_to, _value);
    }

    // Function to mint tokens
    function mint(address _to, uint256 _amount) public onlyValidOwner returns (bool) {
        super.mint(_to, _amount);
    }

    // function to finish the minting and start the transfer of token
    function finishSale() external onlyValidOwner {
        canTransfer = true;
        finishMinting();
    }

    function setSaleStartTime(uint256 _saleStartTime) public onlyValidOwner {
        saleStartTime = _saleStartTime;
    }

    // This function will be used to withdraw 1/3  of the remaining token per 365 days
    function withdrawFromStorage() external onlyValidOwner {
        require(correctTimeFrame(), "Not In Correct Time Frame!");
        require(storageWithdrawCount == 1 || storageWithdrawCount == 2 || storageWithdrawCount == 3, "Not In Correct Time Frame!");
        uint256 tokens = getTokensToWithdraw(storageWithdrawCount);
        balances[COLD_WALLET] = balances[COLD_WALLET].sub(tokens);
        balances[COLD_WALLET_REVERSAL] = balances[COLD_WALLET_REVERSAL].add(tokens);
        emit ColdWalletWithdraw(COLD_WALLET, COLD_WALLET_REVERSAL, tokens);
    }

    function correctTimeFrame() private returns(bool){
        if(now >= (saleStartTime.add(365 days)) && now <= (saleStartTime.add(365*2 days)) && storageWithdrawCount == 0) {
            storageWithdrawCount = storageWithdrawCount.add(1);
            return true;
        } else if(now >= (saleStartTime.add(365*2 days))  &&  now <= (saleStartTime.add(365*3 days)) && storageWithdrawCount == 1) {
            storageWithdrawCount = storageWithdrawCount.add(1);
            return true;
        } else if(now >= (saleStartTime.add(365*3 days))  &&  now <= (saleStartTime.add(365*4 days)) && storageWithdrawCount == 2) {
            storageWithdrawCount = storageWithdrawCount.add(1);
            return true;
        } else  {
            return false;
        }
    }

    // This function will calculate the amount of token to withdraw from cold wallet each year
    function getTokensToWithdraw(uint256 count) private view returns(uint) {
        if(count == 1) {
            return balanceOf(COLD_WALLET).div(3);
        } else if(count == 2) {
            return balanceOf(COLD_WALLET).div(2);
        } else if(count == 3) {
            return balanceOf(COLD_WALLET);
        } else {
            revert();
        }
    }
}