pragma solidity ^0.4.23;

// import 'openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol';

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./NatanConstant.sol";
import "./NatanToken.sol";
// import "./safeDeposit.sol";


contract natanCrowdsale is natanEduConstant, Ownable {
    using SafeMath for uint256;
    natanEduToken public token;
    // safeDeposit public Deposit;
    address public wallet;
    uint public soldTokens;
    uint public hardcap;
    uint public openingTime;
    uint public closingTime;
    bool public isFinalized = false;
    uint public count ;
    bool preico;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary,  uint amount);
    event Finalized();

    /**
    * @dev Reverts if not in crowdsale time range.
    */
    modifier onlyWhileOpen {
        require(block.timestamp >= openingTime && block.timestamp <= closingTime);
        _;
    }

    constructor(uint _openingTime, uint _endTime, address _wallet) public Ownable() {
        require(_endTime >= _openingTime);
        require(_openingTime != 0);
        require(_endTime != 0);
        wallet = _wallet;
        openingTime = _openingTime;
        closingTime = _endTime;
        count = 0;
        preico = true;
        token = createTokenContract();
        token.mint(TEAM_ADDRESS, TEAM_TOKENS);
        token.mint(BONUS_ADDRESS, STUD_BONUS_TOKENS);
        token.mint(PREICO_ADDRESS, PREICO_TOKENS);
        token.mint(NATANEDU_ADDRESS, NATANEDU_FOUNDATION);
        token.mint(DEVELOPMENT_ADDRESS, DEVELOPMENT_TOKENS);
        token.mint(COMMUNITY_ADDRESS, COMMUNITY_TOKENS);
        token.mint(LEGALISSUES_ADDRESS, LEGALISSUES_TOKENS);
        token.mint(COLD_WALLET, LEGALISSUES_TOKENS);

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
        
        if (now <= (openingTime.add(4 days)) ) 
        {
            return 10000*TOKEN_DECIMAL_MULTIPLIER;
        }
        
        else if (now >= (openingTime.add(7 days)) && now <= (openingTime.add(11 days))) 
        {
            return 5000*TOKEN_DECIMAL_MULTIPLIER;
        }

        else if (now >= (openingTime.add(14 days)) && now <= (openingTime.add(17 days))) 
        {
            return 3000*TOKEN_DECIMAL_MULTIPLIER;
        }

        else if (now >= (openingTime.add(32 days)) && now <= (openingTime.add(35 days))) 
        {
            return 1000*TOKEN_DECIMAL_MULTIPLIER;
        }
        else return 500*TOKEN_DECIMAL_MULTIPLIER;
    }

     /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
    function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
    {
        uint rate = getRate();
        require(rate != 0);
        return _weiAmount.mul(rate);
    }


    // low level token purchase function
    function buyTokens(address beneficiary, uint _weiamount) public onlyWhileOpen {
        require(beneficiary != 0x0);
        uint rate = getRate();
        require(rate != 0);
        if(rate == 10000*TOKEN_DECIMAL_MULTIPLIER && soldTokens < PREICO_TOKENS){
            
            // calculate token amount to be created
            uint pretokens = _getTokenAmount(_weiamount);
            require(validPurchase(beneficiary, pretokens,  preico));
            token.mint(beneficiary, tokens);
            soldTokens = soldTokens.add(pretokens);
            TokenPurchase(msg.sender, beneficiary,  pretokens);

        }
        else {
            preico = false;
            // calculate token amount to be created
            uint tokens = _getTokenAmount(_weiamount);
            require(validPurchase(beneficiary, tokens, preico));
            token.mint(beneficiary, tokens);
            soldTokens = soldTokens.add(tokens);
            emit TokenPurchase(msg.sender, beneficiary,  tokens);
        }
    }
    /**
     * @dev Admin can move end time.
     * @param _endTime New end time.
     */
    function setEndTime(uint _endTime) private onlyOwner  {
        require(_endTime > openingTime);
        closingTime = uint32(_endTime);
    }


    function setOpeningTime(uint _openingTime) private onlyOwner  {
        require(_openingTime < closingTime);
        openingTime = uint32(_openingTime);
    }

    // function setHardCap(uint _hardCapTokens) onlyOwner  {
    //     require(_hardCapTokens * TOKEN_DECIMAL_MULTIPLIER > HARD_CAP_TOKENS);
    //     HARD_CAP_TOKENS = _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER;
    // }

    function addExcluded(address _address) public onlyOwner  {
       
        natanEduToken(token).addExcluded(_address);
    }
    // function isSaleFinished() external returns (bool status){
    //     return isFinalized;
    // }

    function getopeningTime() external view returns (uint ) {
        return openingTime;
    }

    function getEndTime() external view returns (uint endtime) {
        return closingTime;
    }

    function validPurchase(address beneficiary, uint tokenamount, bool preico) internal view returns (bool) {
        require(tokenamount >= MINIMAL_PURCHASE);
        require(tokenamount <= MAXIMUM_PURCHASE);
        uint tokenBalance = token.balanceOf(beneficiary);
        require(tokenBalance.add(tokenamount) <= MAXIMUM_PURCHASE);

        if(preico){
            bool softCapNotReached = tokenamount.add(soldTokens) <= PREICO_TOKENS;
            return softCapNotReached;
        }
        else{
            bool hardCapNotReached = tokenamount.add(soldTokens) <= FUND_RAISING_TOKENS;
            return hardCapNotReached;
        }
    }

    // Finalize function for finalizing the crowdsale
    function finalize() public onlyOwner() {
        require(!isFinalized);
        require(hasClosed());

        finalization();
        emit Finalized();

        isFinalized = true;
    }

    /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
    function hasClosed() public view returns (bool) {
        return block.timestamp > closingTime;
    }

    function finalization() internal {
        // super.finalization();
        if(soldTokens <= FUND_RAISING_TOKENS)
        {
            uint amount_to_mint = FUND_RAISING_TOKENS.sub(soldTokens);
            // Deposit = new safeDeposit();
            token.mint (COLD_WALLET,amount_to_mint); // this need to be updated with other logic if smart contract has to be done
        }
        token.finishMinting();
        natanEduToken(token).crowdsaleFinish();
    }

    // This function will be used to withdraw 1/3  of the remaining token per year
    function withdrawFromStorage() public  returns(bool) {
        require(correctTimeFrame());
        require(count == 1 || count == 2 || count == 3);
        token.withdrawFromStorage(count);
        return true;
    }

    function correctTimeFrame() internal returns(bool){
        if(now >= (openingTime.add(1 years)) && now <= (openingTime.add(2 years)) && count == 0)
        {
            count = count.add(1);
            return true;
        }

        else if(now >= (openingTime.add(2 years))  &&  now <= (openingTime.add(3 years)) && count == 1)
        {
            count = count.add(1);
            return true;
        }

        else if(now >= (openingTime.add(3 years))  &&  now <= (openingTime.add(4 years)) && count == 2)
        {
            count = count.add(1);
            return true;
        }

        else return false;
        
    }

}