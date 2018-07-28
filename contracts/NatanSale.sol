pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./NatanConstant.sol";
import "./NatanToken.sol";

contract natanCrowdsale is natanEduConstant, Ownable {
    using SafeMath for uint256;

    natanEduToken public token;   

    uint256 public soldTokens;
    uint256 public openingTime;
    uint256 public closingTime;
    bool public isFinalized;

    // boolean to pause/resume pre sale
    bool public isPaused;

    event TokenAddedColdWallet(address _address, uint256 _tokens);
    event SalePaused(uint256 time);
    event SaleResumed(uint256 time);
    event PreSaleFinished(string reason, uint256 _time);

    /**
    * @dev Reverts if not in crowdsale time range.
    */
    modifier onlyWhileOpen {
        require(!isFinalized, "Sale is finalized!");
        require(!isPaused, "Sale is paused!");
        require(block.timestamp >= openingTime && block.timestamp <= closingTime, "out of sale time");
        _;
    }

    constructor(uint256 _openingTime, uint256 _endTime) public Ownable() {
        require(_endTime >= _openingTime, "end time should be greater then start time!");
        require(_openingTime != 0 && _endTime != 0, "invalid time!");
        openingTime = _openingTime;
        closingTime = _endTime;
        isFinalized = false;

        // create Token instance
        token = new natanEduToken();
        token.transferOwnership(msg.sender);
        token.setSaleStartTime(openingTime);

        // mint token for 42% of NTN allocation wallets address 
        token.mint(TEAM_WALLET, TEAM_TOKENS);
        token.mint(NATANEDU_FOUNDATION_WALLET, NATANEDU_FOUNDATION);
        token.mint(RND_WALLET, DEVELOPMENT_TOKENS);
        token.mint(COMMUNITY_WALLET, COMMUNITY_TOKENS);
        token.mint(STUDENT_BONUS_WALLET, STUD_BONUS_TOKENS);
        token.mint(LEGAL_ISSUES_WALLET, LEGALISSUES_TOKENS);
    }

    //low level token purchase function
    function buyTokens(address beneficiary, uint256 _amountInDollar) public onlyOwner onlyWhileOpen {
        require(beneficiary != 0x0, "invalid address!");
        uint256 rate = getRate();
        uint256 tokens = _amountInDollar.mul(10).div(rate);
        require(isValidPurchase(beneficiary, tokens), "Not a valid purchase!");
        token.mint(beneficiary, tokens);
        soldTokens = soldTokens.add(tokens);

        // check if hardcap of pre sale is reached
        if(soldTokens == PREICO_TOKENS) {
            emit PreSaleFinished("Hardcap Reached", block.timestamp);
        } else if(soldTokens == FUND_RAISING_TOKENS) {
            emit PreSaleFinished("Hardcap Reached", block.timestamp);
        }
    }

    // get rate in dollar multiplied by 10 to support float value for 1 token
    function getRate() private view returns (uint256) {
        if (now <= (openingTime.add(4 days))) {
            return 6; // $0.6
        } else if (now > openingTime.add(6 days) && now <= openingTime.add(11 days)) {
            return 7; // $0.7
        } else if (now > (openingTime.add(14 days)) && now <= (openingTime.add(18 days))) {
            return 8; // $0.8
        } else {
            return 10; // $1
        }
    }

    function isPresale() private view returns (bool) {
        return now <= openingTime.add(18 days);
    }

    function isValidPurchase(address beneficiary, uint256 tokenamount) private view returns (bool) {
        require(tokenamount >= MINIMAL_PURCHASE, "Amount is less then min purchase limit!");
        require(tokenamount <= MAXIMUM_PURCHASE, "Amount is greater then max purchase limit!");
        require(token.balanceOf(beneficiary).add(tokenamount) <= MAXIMUM_PURCHASE, "Not allowed to purchase more then max limit!");
        if(isPresale()){
            require(soldTokens.add(tokenamount) <= PREICO_TOKENS, "Pre Sale hard cap is reached!");
        } else {
            require(soldTokens.add(tokenamount) <= FUND_RAISING_TOKENS, "Crowd Sale hard cap is reached!");
        }
        return true;
    }

    // function to change open time 
    function setOpeningTime(uint256 _openingTime) external onlyOwner  {
        require(_openingTime < closingTime, "opening time should be smaller then end time!");
        openingTime = _openingTime;
    }

    // function to change end time 
    function setEndTime(uint256 _endTime) external onlyOwner {
        require(_endTime > openingTime, "end time should be greater then start time!");
        closingTime = _endTime;
    }

     /**
    * @dev external function for contract owner to pause the sale
    */
    function pauseSale() external onlyOwner onlyWhileOpen {
        isPaused = true;
        emit SalePaused(block.timestamp);
    }

    /**
    * @dev external function for contract owner to resume the sale if paused
    */
    function resumeSale() external onlyOwner {
        require(!isFinalized, "Sale is finalized!");
        require(isPaused, "Sale is already resumed!");
        require(block.timestamp >= openingTime && block.timestamp <= closingTime, "out of sale time");
        isPaused = false;
        emit SaleResumed(block.timestamp);
    }

    // Finish Crowdsale
    // function finishCrowdsale() external onlyOwner {
    //     require(!isFinalized, "Already finalized the sale!");
    //     token.finishSale();
    //     isFinalized = true;
    // }

    // function to finalize sale so that remaining token will be transfered to storage wallet
    function finalizeSale() public onlyOwner {
        require(!isFinalized, "Already finalized the sale!");
        require(hasClosed(), "sale is still on!");
        transferRemainToStorage();
        isFinalized = true;
    }

    // function to transfer remaining un sold token to cold wallet afer the sale is finished.
    function transferRemainToStorage() private {
        if(soldTokens < FUND_RAISING_TOKENS) {
            uint256 remainingTokens = FUND_RAISING_TOKENS.sub(soldTokens);
            token.mint(COLD_WALLET, remainingTokens);
            emit TokenAddedColdWallet(COLD_WALLET, remainingTokens);
        }
        token.finishSale();
    }

    /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
    function hasClosed() public view returns (bool) {
        return block.timestamp > closingTime;
    }
}