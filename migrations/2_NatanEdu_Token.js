var NatanEduToken = artifacts.require("./natanEduToken.sol");

module.exports = function(deployer) {
  deployer.deploy(NatanEduToken);
};
