pragma solidity ^0.4.23;


contract natanEduConstant {
    uint constant TOKEN_DECIMALS = 18;
    uint8 constant TOKEN_DECIMALS_UINT8 = 18;
    uint constant TOKEN_DECIMAL_MULTIPLIER = 10 ** TOKEN_DECIMALS;

    uint constant TEAM_TOKENS =  7600000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant STUD_BONUS_TOKENS =  4750000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant PREICO_TOKENS = 1653000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant NATANEDU_FOUNDATION = 4750000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant DEVELOPMENT_TOKENS = 14250000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant COMMUNITY_TOKENS = 3800000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant LEGALISSUES_TOKENS = 4750000 * TOKEN_DECIMAL_MULTIPLIER;

    uint constant MINIMAL_PURCHASE = 2 ether;
    uint constant MAXIMUM_PURCHASE = 50 ether;

    address constant TEAM_ADDRESS = 0xaa91976bedc33ac661fa2d25b22601d823ac2582;
    address constant BONUS_ADDRESS = 0xc803D536FFb1eC9B71548352784FAAeCF95929a9;
    address constant PREICO_ADDRESS = 0x7b1593b7ee429a0bc1aa86a6c92888cf5304f97c;
    address constant NATANEDU_ADDRESS = 0x7b1593b7ee429a0bc1aa86a6c92888cf5304f97c;
    address constant DEVELOPMENT_ADDRESS = 0x7b1593b7ee429a0bc1aa86a6c92888cf5304f97c;
    address constant COMMUNITY_ADDRESS = 0x7b1593b7ee429a0bc1aa86a6c92888cf5304f97c;
    address constant LEGALISSUES_ADDRESS = 0x7b1593b7ee429a0bc1aa86a6c92888cf5304f97c;
    address constant COLD_WALLET = 0xc803D536FFb1eC9B71548352784FAAeCF95929a9;

    string constant TOKEN_NAME = "Natan Edu";
    string constant TOKEN_SYMBOL = "NTN";
}