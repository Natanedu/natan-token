pragma solidity ^0.4.23;

contract natanEduConstant {
    uint constant TOKEN_DECIMALS = 18;
    uint8 constant TOKEN_DECIMALS_UINT8 = 18;
    uint constant TOKEN_DECIMAL_MULTIPLIER = 10 ** TOKEN_DECIMALS;

    // Total tokens that will be minted ever 100%
    uint constant HARD_CAP_TOKENS = 95000000 * TOKEN_DECIMAL_MULTIPLIER;

    // for team 8%
    uint constant TEAM_TOKENS =  7600000 * TOKEN_DECIMAL_MULTIPLIER;

    // natan foundation 5%
    uint constant NATANEDU_FOUNDATION = 4750000 * TOKEN_DECIMAL_MULTIPLIER;

    // development 15%
    uint constant DEVELOPMENT_TOKENS = 14250000 * TOKEN_DECIMAL_MULTIPLIER;

    // for community 4%
    uint constant COMMUNITY_TOKENS = 3800000 * TOKEN_DECIMAL_MULTIPLIER;

    // for student bonus 5%
    uint constant STUD_BONUS_TOKENS =  4750000 * TOKEN_DECIMAL_MULTIPLIER;

    // for legal issues 5%
    uint constant LEGALISSUES_TOKENS = 4750000 * TOKEN_DECIMAL_MULTIPLIER;

    // need to raise fund 58%
    uint constant FUND_RAISING_TOKENS = 55100000 * TOKEN_DECIMAL_MULTIPLIER;

    // 3% of fund raising tokens
    uint constant PREICO_TOKENS = 1653000 * TOKEN_DECIMAL_MULTIPLIER;

    uint constant MINIMAL_PURCHASE = 100 * TOKEN_DECIMAL_MULTIPLIER; //100 NTN 
    uint constant MAXIMUM_PURCHASE = 500 * TOKEN_DECIMAL_MULTIPLIER; //500 NTN MAX 

    // wallets address for 42% of NTN allocation
    address constant TEAM_WALLET = 0xD04a4314b46Ac2e2f27FDa6eFC69DA629b5621d1;
    address constant NATANEDU_FOUNDATION_WALLET = 0x7b1593B7ee429a0bC1aa86a6c92888cf5304F97c;
    address constant RND_WALLET = 0x7b1593B7ee429a0bC1aa86a6c92888cf5304F97c;
    address constant COMMUNITY_WALLET = 0x7b1593B7ee429a0bC1aa86a6c92888cf5304F97c;
    address constant STUDENT_BONUS_WALLET = 0xc803D536FFb1eC9B71548352784FAAeCF95929a9;
    address constant LEGAL_ISSUES_WALLET = 0x7b1593B7ee429a0bC1aa86a6c92888cf5304F97c;

    // address for deposit and withdrwal of remaining tokens after sale
    address constant COLD_WALLET = 0xc803D536FFb1eC9B71548352784FAAeCF95929a9;
    address constant COLD_WALLET_REVERSAL = 0x7b1593B7ee429a0bC1aa86a6c92888cf5304F97c;

    string constant TOKEN_NAME = "Natan Edu";
    string constant TOKEN_SYMBOL = "NTN";
}