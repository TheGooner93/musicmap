var Curator = artifacts.require("Curator");
module.exports = function(deployer) {
  deployer.deploy(Curator);
};