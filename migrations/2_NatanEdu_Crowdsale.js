var NatanTokenSale = artifacts.require("./natanCrowdsale.sol");

module.exports = function(deployer) {
  deployer.deploy(NatanTokenSale,1499666984,1533467659,"0xd04a4314b46ac2e2f27fda6efc69da629b5621d1");
};
