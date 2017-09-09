/*
var bip39 = require("bip39");
var hdkey = require('ethereumjs-wallet/hdkey');
var ProviderEngine = require("web3-provider-engine");
var WalletSubprovider = require('web3-provider-engine/subproviders/wallet.js');
var Web3Subprovider = require("web3-provider-engine/subproviders/web3.js");
var FilterSubprovider = require("web3-provider-engine/subproviders/filters.js");
var Web3 = require("web3");
var HDWalletProvider = require("truffle-hdwallet-provider");

// Get our mnemonic and create an hdwallet
var mnemonic = "couch solve unique spirit wine fine occur rhythm foot feature glory away";
var hdwallet = hdkey.fromMasterSeed(bip39.mnemonicToSeed(mnemonic));

// Get the first account using the standard hd path.
var wallet_hdpath = "m/44'/60'/0'/0/";
var wallet = hdwallet.derivePath(wallet_hdpath + "0").getWallet();
var address = "0x" + wallet.getAddress().toString("hex");

var providerUrl = "https://testnet.infura.io";
var engine = new ProviderEngine();
engine.addProvider(new WalletSubprovider(wallet, {}));
engine.addProvider(new Web3Subprovider(new Web3.providers.HttpProvider(providerUrl)));
engine.addProvider(new FilterSubprovider())
engine.start(); // Required by the provider engine.
*/
module.exports = {
  networks: {
    rinkeby: {
      host: "localhost",
      network_id: 4,
      from: "0x7cd8875283748611df86aEB3e66f887066559f66",
      gas: 4701000,
			gasprice: 15000000
    },
    ropsten: {
      host: "localhost",
      port: 8545,
      network_id: "3",
      from: "0x4559C785B6153EDDa080234cE2828575B12E967C",
      gas: 4701000,
			gasprice: 15000000
    },
    develop: {
      host: "localhost",
      port: 8546,
      network_id: "*", // Match any network id
      gas: 4701000,
			gasprice: 15000000
    }
  }
};
