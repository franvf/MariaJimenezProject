const collection = artifacts.require("MariaCollection");

module.exports = function (deployer) {
  deployer.deploy(collection);
};
