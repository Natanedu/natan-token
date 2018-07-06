pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol';
import './natanEduConstant.sol';
import './natanEduToken.sol'


contract natanCrowdsale is natanEduConstant, FinalizableCrowdsale {

    function natanCrowdsale(uint startTime, uint endTime, uint _hardCapTokens)
            FinalizableCrowdsale(startTime, endTime, _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER, COLD_WALLET) {

        token.mint(TEAM_ADDRESS, TEAM_TOKENS);
        token.mint(BONUS_ADDRESS, STUD_BONUS_TOKENS);
        token.mint(PREICO_ADDRESS, PREICO_TOKENS);
        token.mint(NATANEDU_ADDRESS, NATANEDU_FOUNDATION);
        token.mint(DEVELOPMENT_ADDRESS, DEVELOPMENT_TOKENS);
        token.mint(COMMUNITY_ADDRESS, COMMUNITY_TOKENS);
        token.mint(LEGALISSUES_ADDRESS, LEGALISSUES_TOKENS);

        natanEduToken(token).addExcluded(TEAM_ADDRESS);
        natanEduToken(token).addExcluded(BOUNTY_ADDRESS);
        natanEduToken(token).addExcluded(PREICO_ADDRESS);
    }

    /**
     * @dev override token creation to integrate with natanEduToken token.
     */
    function createTokenContract() internal returns (MintableToken) {
        return new natanEduToken();
    }

    // @return the rate in NTN per 1 ETH according to the time of the tx and the SRN pricing program.
    // @Override
    function getRate() public view returns (uint256) {
        
        if (now < (startTime.add(3 days)) ) 
        {
            return 10000*TOKEN_DECIMAL_MULTIPLIER;
        }
        
        if (now < (startTime.add(7 days))) 
        {
            return 5000*TOKEN_DECIMAL_MULTIPLIER;
        }

        if (now < (startTime.add(13 days))) 
        {
            return 3000*TOKEN_DECIMAL_MULTIPLIER;
        }

        if (now < (startTime.add(31 days))) 
        {
            return 1000*TOKEN_DECIMAL_MULTIPLIER;
        }

        return rate;
    }


    /**
     * @dev Admin can set new rate provider.
     * @param _rateProviderAddress New rate provider.
     */
    function setRateProvider(address _rateProviderAddress) onlyOwner {
        require(_rateProviderAddress != 0);
        rateProvider = RateProviderI(_rateProviderAddress);
    }

    /**
     * @dev Admin can move end time.
     * @param _endTime New end time.
     */
    function setEndTime(uint _endTime) onlyOwner notFinalized {
        require(_endTime > startTime);
        endTime = uint32(_endTime);
    }

    function setHardCap(uint _hardCapTokens) onlyOwner notFinalized {
        require(_hardCapTokens * TOKEN_DECIMAL_MULTIPLIER > hardCap);
        hardCap = _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER;
    }

    function setStartTime(uint _startTime) onlyOwner notFinalized {
        require(_startTime < endTime);
        startTime = uint32(_startTime);
    }

    function addExcluded(address _address) onlyOwner notFinalized {
       natanEduToken(token).addExcluded(_address);
    }

    function validPurchase(uint _amountWei, uint _actualRate, uint _totalSupply) internal constant returns (bool) {
        if (_amountWei < MINIMAL_PURCHASE) {
            return false;
        }
        return super.validPurchase(_amountWei, _actualRate, _totalSupply);
    }

    function finalization() internal {
        super.finalization();
        token.finishMinting();
        natanEduToken(token).crowdsaleFinish();
        token.transferOwnership(owner);
    }

    function isSaleFinished() external returns (bool status){
        return isFinalized;
    }

    function getStartTime() external constant returns (uint starttime) {
        return startTime;
    }

    function getEndTime() external constant returns (uint endtime) {
        return endTime;
    }

    function buynatanEduTokens(address beneficiary,uint amountWei) onlyOwner {
        buyTokens(beneficiary, amountWei);
    }
}