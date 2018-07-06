pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol';
import './natanEduConstant.sol';


contract natanEduToken is  natanEduConstant, MintableToken {

    /**
     * @dev Pause token transfer. After successfully finished crowdsale it becomes true.
     */
    bool public paused = false;
    /**
     * @dev Accounts who can transfer token even if paused. Works only during crowdsale.
     */
    mapping(address => bool) excluded;

    
    function name() constant public returns (string _name) {
        return TOKEN_NAME;
    }

    function symbol() constant public returns (string _symbol) {
        return TOKEN_SYMBOL;
    }

    function decimals() constant public returns (uint _decimals) {
        return TOKEN_DECIMALS;
    }

    function crowdsaleFinish() onlyOwner {
        paused = true;
        finishMinting();
    }

    function addExcluded(address _toExclude) onlyOwner {
        excluded[_toExclude] = true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        require(!paused || excluded[_from]);
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) returns (bool) {
        require(!paused || excluded[msg.sender]);
        return super.transfer(_to, _value);
    }

}