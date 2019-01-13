var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = 'column force race fiscal uniform knife swing copper shallow draw syrup tank';
module.exports = {
  networks: {
    ropsten: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/OE53o8rzoO0gjA5o8xC1")
      },
      gas: 4600000,
      network_id: 3
    }
  }
};
