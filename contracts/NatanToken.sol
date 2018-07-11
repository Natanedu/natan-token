pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "./NatanConstant.sol";

contract natanEduToken is  natanEduConstant, MintableToken {

    /**
     * @dev Pause token transfer. After successfully finished crowdsale it becomes true.
     */
    bool public paused = false;
    uint _count;
    address sale_Add;

    /**
    * @dev Accounts who can transfer token even if paused. Works only during crowdsale.
    */
    mapping(address => bool) excluded;
    event CheckMSGSender(address owner);
    event StorageWithDraw(address _to, address _from, uint value);

    constructor() public {
        sale_Add = msg.sender;
    }

    /**
    * @dev Throw an exception if called by any account other than the crowdsaleAddress.
    */
    modifier onlySale() {
        require(msg.sender == sale_Add);
        _;
    }

    function name() public view returns (string _name) {
        emit CheckMSGSender(sale_Add);
        return TOKEN_NAME;
    }

    function symbol() public pure returns (string _symbol) {
        return TOKEN_SYMBOL;
    }

    function decimals() public pure returns (uint _decimals) {
        return TOKEN_DECIMALS;
    }

    function crowdsaleFinish() external onlyOwner() {
        paused = true;
        finishMinting();
    }

    function setCrowdsaleAddress() {

    }

    function addExcluded(address _toExclude) onlyOwner() {
        excluded[_toExclude] = true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(!paused || excluded[_from]);
        require(_from != COLD_WALLET && _to != COLD_WALLET);
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(!paused || excluded[msg.sender]);
        require(_to != COLD_WALLET);
        return super.transfer(_to, _value);
    }

    /**
    * @dev Function to mint tokens
    */
    function mint(address _to, uint256 _amount) public returns (bool) {
        super.mint(_to, _amount);
    }

    // This function will be used to withdraw 1/3  of the remaining token per year
    function withdrawFromStorage(uint count) external onlySale() returns(bool) {
        // require(msg.sender = this);
        emit CheckMSGSender(msg.sender);
        _count = count;
        uint value = withdrawAmount(_count);
        balances[COLD_WALLET] = balances[COLD_WALLET].sub(value);
        balances[NATANEDU_ADDRESS] = balances[NATANEDU_ADDRESS].add(value);
        emit StorageWithDraw(COLD_WALLET,NATANEDU_ADDRESS, value);
        return true;
    }

    // This function will calculate the amount of token to withdraw from cold wallet each year
    function withdrawAmount(uint count) internal view returns(uint) {
        if(count == 1){
            return balanceOf(COLD_WALLET).div(3);
        }
        else if(count == 2){
            return balanceOf(COLD_WALLET).div(2);
        }
        else if(count == 3){
            return balanceOf(COLD_WALLET);
        }
        else revert();
    }
}