var Migrations = artifacts.require("./Migrations.sol");
var Curator = artifacts.require("./Curator.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Curator);
};
