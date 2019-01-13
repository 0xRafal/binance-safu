let chai = require('chai')
let expect = chai.expect;
let chaiHttp = require('chai-http');
chai.use(chaiHttp);
let should = chai.should();
var HexFramework = require('../lib/hexFramework');
let framework = new HexFramework('test',{startPluginManager:false});
let modelName = 'blankPlugin';
let plugin=framework.loadPlugin('/../plugins/BlankPlugin/plugin','BlankPlugin');
//var Plugin = require('../plugins/BlankPlugin/plugin');
framework.emitEvent("inited","Ignore this test message");
describe('HexFramework', function () {
  it('should be an object', function () {
    expect(typeof framework).to.be.equal("object");
  });
  it('should have version 0.1.4', function () {
    expect(framework.version).to.be.equal("0.1.4")
  });
  it('should be development mode', function () {
    expect(framework.env('NODE_ENV')).to.be.equal('development')
  })
  it('should have function logger', function () {
    expect(typeof framework.logger).to.be.equal("function");
  });
  it('should have utility as object', function () {
    expect(typeof framework.utility).to.be.equal("object");
  });
  it('should run logger for info type properly', function () {
    expect(typeof framework.logger("info","Framework logger info test.")).to.be.equal("undefined");
  });
  it('should run logger for error type properly', function () {
    expect(typeof framework.logger("error","Framework logger error message.")).to.be.equal("undefined");
  });
});
describe('Utility', function () {
  let utility = framework.utility;
  it('should be an object', function () {
    expect(typeof utility).to.be.equal("object")
  });
  it('should have version 0.0.4', function () {
    expect(utility.version).to.be.equal("0.1.5")
  });
  describe('formatDate()',function () {
    let testDate = new Promise(function(resolve, reject) {
      var date = new Date(2018,8,1,15,1);
      resolve(utility.formatDate(date))
    });
    it('should return "September 1, 2018 at 15:01:00 PM" for Date Object', async function () {
      let result = await testDate;
      expect(result).to.be.equal('September 1, 2018 at 15:01:00 PM');
    });
  });
  describe('getScheduledTime()',function () {
    var date = new Date(2018,8,1,15,1);
    describe('Cold',function () {
      it('should return "September 1, 2018 at 15:01:00 PM" for Date Object', async function () {
        let result = await utility.getScheduledTime(date, 'ZeroKey');
        expect(result).to.be.equal('September 1, 2018 at 15:01:00 PM');
      });
    });
    describe('Frozen',function () {
      it('should return "September 2, 2018 at 15:01:00 PM" for Date Object', async function () {
        let result = await utility.getScheduledTime(date, 'Frozen');
        expect(result).to.be.equal('September 2, 2018 at 15:01:00 PM');
      });
    });
  });
  describe('getLocation()',function () {
    it('should return "Private Network" for "192.168.0.1"', async function () {
      let result = await utility.getLocation('192.168.0.1');
      expect(result).to.be.equal('Private Network');
    });
  });
  describe('verifyQuantity()',function () {
    describe('QuantityIsZero',function () {
      it('should return false for 0', async function () {
        let result = await utility.verifyQuantity('0.0000');
        expect(result).to.be.equal(false);
      });
      it('should return false for 0.0000', async function () {
        let result = await utility.verifyQuantity('0');
        expect(result).to.be.equal(false);
      });
    });
    describe('QuantityLargerThenMaxValue',function () {
      it('should return false for quantity 23.3413 & maxValue 23', async function () {
        let result = await utility.verifyQuantity('23.3413',23);
        expect(result).to.be.equal(false);
      });
    });
    describe('InvalidQuantityFormat',function () {
      it('should return false for quantity 4.25522', async function () {
        let result = await utility.verifyQuantity('4.25522',24);
        expect(result).to.be.equal(false);
      });
      it('should return false for quantity 2.a3sd', async function () {
        let result = await utility.verifyQuantity('2.a3sd',24);
        expect(result).to.be.equal(false);
      });
    });
    describe('ValidQuantity',function () {
      it('should return true for quantity 21,000.2552', async function () {
        let result = await utility.verifyQuantity('21,000.2552',24000);
        expect(result).to.be.equal(true);
      });
    });
  });
  describe('verifyCurrency()',function () {
    describe('CurrencyIsZero',function () {
      it('should return false for 0', async function () {
        let result = await utility.verifyCurrency('0');
        expect(result).to.be.equal(true);
      });
    });
    describe('CurrencyLargerThenMaxValue',function () {
      it('should return false for currency 25,000 & maxValue 24', async function () {
        let result = await utility.verifyCurrency('25,000',24);
        expect(result).to.be.equal(false);
      });
    });
    describe('InvalidCurrencyFormat',function () {
      it('should return false for currency 2a3sd', async function () {
        let result = await utility.verifyCurrency('2a3sd',24);
        expect(result).to.be.equal(false);
      });
    });
    describe('ValidCurrency',function () {
      it('should return true for currency 4.25522', async function () {
        let result = await utility.verifyCurrency('25,000',26000);
        expect(result).to.be.equal(true);
      });
      it('should return true for currency 00005', async function () {
        let result = await utility.verifyCurrency('00005');
        expect(result).to.be.equal(true);
      });
    });
  });
  describe('trimInputs()',function () {
    describe('InvalidInputs',function () {
      it('should trim input for "<234/><svcc"', async function () {
        let result = await utility.trimInputs('<234/><svcc');
        expect(result).to.be.equal('<svcc');
      });
    });
    describe('ValidInputs',function () {
      it('should not trim input for "Transfering to 552asd"', async function () {
        let result = await utility.trimInputs('Transfering to 552asd');
        expect(result).to.be.equal('Transfering to 552asd');
        framework.stop()

      });
    });
  });
});
