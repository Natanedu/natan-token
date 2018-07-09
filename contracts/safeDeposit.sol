pragma solidity ^0.4.23;

// import "node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
// import "./natanEduToken.sol";

contract safeDeposit   {
// using SafeMath for uint256;

    function transferToken()public {
      require(balances[this] > 0);
    }

}