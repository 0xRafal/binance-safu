const addressData = require('../../JsonData/address.json');
const rp = require('request-promise');
const addressReportRequest = require('../../JsonData/address_report_request.json');
const etherscamAddressScoreEndpoint = "https://etherscamdb.info/api/check";
const bigdecimal = require('bigdecimal');
const fs = require('fs');
class Service {
  constructor(model) {
    model.addService(this);
  }
  async getAddressScore(req) {
    try {
      let address = req.body.address;
      let {overallScore, etherscamDbScore, etherscanScore, communityScore} = await this.calculateAddressScore(address);
      let description = await this.getAddressDescription(address);
      let isWhitelisted = await this.isWhitelisted(address); 
      let address_data = {
        "address": req.body.address,
        "overall_score": overallScore,
        "description": description,
        "etherscam_score": etherscamDbScore,
        "etherscan_score": etherscanScore,
        "community_score": communityScore,
        "is_whitelisted": isWhitelisted,
        "graph_style": 'wide',
        "graph_score": 20
      };
      await this.writeDataToAddressData(address_data);
      if (typeof addressData[address] != 'undefined') {
        return address_data;
      }
    } catch (error) {
      console.log(error);
    }
  }
  async submitAddressRequest(req) {
    try {
      let address = req.body.address;
      let report_message = req.body.report_message;
      let user_name = req.body.user_name;
      let user_karma = req.body.user_karma;
      await this.writeDataToAddressReportRequest(req.body);
      return;
    } catch (error) {
      console.log(error)
    }
  }
  async calculateAddressScore(address) {
    console.log('enter calc address');
    let etherscamDbScore = await this.getScoreFromEtherscamDb(address);
    let etherscanScore = await this.getScoreFromEtherscan(address);
    let communityScore = await this.getScoreFromCommunity(address);
    let overallScore = (etherscamDbScore * 0.3 + etherscanScore * 0.3 + communityScore * 0.6) / (etherscamDbScore + etherscanScore + communityScore);
    if (addressData[address].is_whitelisted) {
      if (overallScore <= 25) {
        overallScore = 0;
      }
    }
    return {overallScore, etherscamDbScore, etherscanScore, communityScore};
  }
  async writeDataToAddressReportRequest(requestData){
    let requestId = 0;
    if (addressReportRequest.length != 0) {
      requestId = addressReportRequest.length;
    }
    addressReportRequest.push({
      "requestId": requestId,
      "address": requestData.address,
      "report_message": requestData.report_message,
      "user_name": requestData.user_name,
      "user_karma": requestData.user_karma
    });
    console.log(addressReportRequest);
    let addressReportRequestString = JSON.stringify(addressReportRequest);
    fs.writeFile('plugins/JsonData/address_report_request.json', addressReportRequestString, (err) => {
      if (err) console.log(err);
    });
    return;
  }
  async getAddressDescription(address){
    return addressData[address].description;
  }
  async isWhitelisted(address){
    return addressData[address].is_whitelisted;
  }
  async writeDataToAddressData(data){
    addressData[data.address] = {
      "overall_score": data.overall_score,
      "description": data.description,
      "etherscam_score": data.etherscam_score,
      "community_score": data.community_score,
      "is_whitelisted": data.is_whitelisted
    }
    let addressDataString = JSON.stringify(addressData);
    fs.writeFile('plugins/JsonData/address.json', addressDataString, (err) => {
      if (err) console.log(err);
    });
    return;
  }
  async getScoreFromEtherscamDb(addressId){
    let url_string = `${etherscamAddressScoreEndpoint}/${addressId}/`;
    let options = {
      uri : url_string,
      headers: {
        'User-Agent': 'Request-Promise'
      },
      json: true
    };
    const etherscamAddressData = await rp(options);
    let addressStatus = etherscamAddressData.result;
    if (addressStatus == "blocked") {
      return 100;
    } else {
      return 0;
    }
  }
  async getScoreFromEtherscan(addressId){
    return 0;
  }
  async getScoreFromCommunity(addressId){
    console.log('get score');
    let addrReqHashmap = {};
    for (let i = 0; i < addressReportRequest.length; i++) {
      let addrReq = addressReportRequest[i];
      if (typeof addrReqHashmap[addrReq.address] == 'undefined') {
        addrReqHashmap[addrReq.address] = addrReq.user_karma / 10;
      }
      addrReqHashmap[addrReq.address] += addrReq.user_karma / 10;
      console.log(addrReqHashmap[addrReq.address]);
    }

    return addrReqHashmap[addressId];
  }
  async getAddressTxData(req){
    try {
      console.log('enter the func');
      console.log(req.body.address);
      let toCount = 0;
      let fromCount = 0;
      const etherscanAddressDataEndpoint = `http://api.etherscan.io/api?module=account&action=txlist&address=${req.body.address}&apikey=YourApiKeyToken`;
      const etherscanAddressBalanceEndpoint = `https://api.etherscan.io/api?module=account&action=balance&address=${req.body.address}bae&tag=latest&apikey=YourApiKeyToken`
      const options = {
        uri : etherscanAddressDataEndpoint,
        headers: {
          'User-Agent': 'Request-Promise'
        },
        json: true
      };
      const etherscanAddrDataJSON = await rp(options);
      console.log(etherscanAddrDataJSON);
      let etherscanAddrData = etherscanAddrDataJSON.result;
      for (let i = 0; i < etherscanAddrData.length; i++) {
        if (etherscanAddrData[i].to == req.body.address.toLowerCase()) {
          toCount++;
        } else if (etherscanAddrData[i].from == req.body.address.toLowerCase()) {
          fromCount++;
        }
      }
      const options2 = {
        uri : etherscanAddressBalanceEndpoint,
        headers: {
          'User-Agent': 'Request-Promise'
        },
        json: true
      }
      let etherscanAddrBalanceData = await rp(options2);
      let etherscanBalance = etherscanAddrBalanceData.result;
      console.log(etherscanBalance);
      etherscanBalance = (new bigdecimal.BigDecimal(etherscanBalance).divide(new bigdecimal.BigDecimal('1000000000000000000'))).toString();
      let totalCount = toCount + fromCount;
      return {'total_count': totalCount, 'to_count': toCount, 'from_count': fromCount, 'balance': etherscanBalance};
    } catch (error) {
      console.log(error);
    }
  }
}
module.exports = Service;
