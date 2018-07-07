var BibleTokenCore = artifacts.require("./BibleTokenCore.sol");

module.exports = function(deployer) {
    // Deploys the BibleToken contract
    deployer.deploy(BibleTokenCore, {
	gas: 6000000
    });
};
