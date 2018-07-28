var NatanTokenSale = artifacts.require("./natanCrowdsale.sol");

module.exports = function(deployer) {
  deployer.deploy(NatanTokenSale,1499666984,1533467659);
};
