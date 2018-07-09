pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol';

import './natanEduConstant.sol';
import './natanEduToken.sol';


contract natanCrowdsale is natanEduConstant, FinalizableCrowdsale {

    natanEduToken public token;
    address public wallet;
    uint public soldTokens;
    uint public hardcap;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary,  uint amount);


    constructor(uint openingTime, uint endTime, address _wallet)
            TimedCrowdsale(openingTime, endTime) {
        
        require(endTime >= openingTime);
        wallet = _wallet;
        token = createTokenContract();
        token.mint(TEAM_ADDRESS, TEAM_TOKENS);
        token.mint(BONUS_ADDRESS, STUD_BONUS_TOKENS);
        token.mint(PREICO_ADDRESS, PREICO_TOKENS);
        token.mint(NATANEDU_ADDRESS, NATANEDU_FOUNDATION);
        token.mint(DEVELOPMENT_ADDRESS, DEVELOPMENT_TOKENS);
        token.mint(COMMUNITY_ADDRESS, COMMUNITY_TOKENS);
        token.mint(LEGALISSUES_ADDRESS, LEGALISSUES_TOKENS);

        natanEduToken(token).addExcluded(TEAM_ADDRESS);
        natanEduToken(token).addExcluded(BONUS_ADDRESS);
        natanEduToken(token).addExcluded(PREICO_ADDRESS);
    }

    /**
     * @dev override token creation to integrate with natanEduToken token.
     */
    function createTokenContract() internal returns (natanEduToken) {
        return new natanEduToken();
    }

    // @return the rate in NTN per 1 ETH according to the time of the tx and the SRN pricing program.
    // @Override
    function getRate() public view returns (uint256) {
        
        if (now <= (openingTime.add(3 days)) ) 
        {
            return 10000*TOKEN_DECIMAL_MULTIPLIER;
        }
        
        else if (now <= (openingTime.add(10 days))) 
        {
            return 5000*TOKEN_DECIMAL_MULTIPLIER;
        }

        else if (now <= (openingTime.add(16 days))) 
        {
            return 3000*TOKEN_DECIMAL_MULTIPLIER;
        }

        else if (now <= (openingTime.add(34 days))) 
        {
            return 1000*TOKEN_DECIMAL_MULTIPLIER;
        }
    }



   

     // low level token purchase function
    function buyTokens(address beneficiary, uint amount) public {
        require(beneficiary != 0x0);
        // total minted tokens
        uint totalSupply = token.totalSupply();
        // calculate token amount to be created
        uint tokens = getRate();
        // actual token minting rate (with considering bonuses and discounts)
        require(validPurchase(tokens, totalSupply));
        soldTokens = soldTokens.add(tokens);
        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary,  tokens);
    }
    /**
     * @dev Admin can move end time.
     * @param _endTime New end time.
     */
    function setEndTime(uint _endTime) onlyOwner  {
        require(_endTime > openingTime);
        closingTime = uint32(_endTime);
    }


     function setopeningTime(uint _openingTime) onlyOwner  {
        require(_openingTime < closingTime);
        openingTime = uint32(_openingTime);
    }

    // function setHardCap(uint _hardCapTokens) onlyOwner  {
    //     require(_hardCapTokens * TOKEN_DECIMAL_MULTIPLIER > HARD_CAP_TOKENS);
    //     HARD_CAP_TOKENS = _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER;
    // }

   

    function addExcluded(address _address) onlyOwner  {
       natanEduToken(token).addExcluded(_address);
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

    function getopeningTime() external constant returns (uint openingTime) {
        return openingTime;
    }

    function getEndTime() external constant returns (uint endtime) {
        return closingTime;
    }

    function buynatanEduTokens(address beneficiary,uint amountWei) onlyOwner {
        buyTokens(beneficiary, amountWei);
    }

    function validPurchase(uint tokenamount, uint _totalSupply) internal constant returns (bool) {
        require(tokenamount >=  MINIMAL_PURCHASE );
        require(tokenamount <= MAXIMUM_PURCHASE);
        bool withinPeriod = now >= openingTime && now <= closingTime;
        uint checkamount = tokenamount.add(_totalSupply);
        bool hardCapNotReached = checkamount <= HARD_CAP_TOKENS;
        return withinPeriod  && hardCapNotReached;
    }
}