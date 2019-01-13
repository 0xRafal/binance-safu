const IcoToken = artifacts.require('IcoToken');
const IcoContract = artifacts.require('IcoContract');

module.exports = function(deployer) {
  deployer.deploy(
    IcoToken,
    'Arma Token',
    'ARMA',
    '18',
    '1.0'
  ).then(() => {
    return deployer.deploy(
      IcoContract,
      '0x64e04656b9011Ae836a4287ce0fB7753710d1Bcd', // Your ETH Address
      IcoToken.address,
      '1000000000000000000000000000', // 1,000,000,000 GBO
      '5000', // 1 ETH = 500 ARMA TOKEN
      '1547078400',// start date - 10th jan 2019
      '1549756800', // end date - 10th feb 2019
      '100000000000000000' // Min 0.1 ETH
    ).then(() => {
      return IcoToken.deployed().then(function(instance) {
        return instance.setIcoContract(IcoContract.address);
      });
    });
  });
};
