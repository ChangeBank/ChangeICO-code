var ChangeCoinPresale = artifacts.require("ChangeCoinPresale.sol")

module.exports = function(deployer, network, accounts) {
  deployer.deploy(ChangeCoinPresale)
}
