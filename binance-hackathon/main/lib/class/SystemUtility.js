const updateVersion = '0.1.5';
const updateDate  = '2018-12-28';
const appName = 'Utility';

const setSystem = require('../util/setSystem');
const bigdecimal = require("bigdecimal");
const BigNumber = require('bignumber.js');
var rp = require('request-promise');
var useragent = require('useragent');

const specialCharacterDecode = {"&&atty;":"ä","&&atte;":"â","&&ette;":"ê", "&&itty;":"î","&&otty;":"ô", "&&utty;":"û"}
class Utility{
  constructor( system ){
    require('../util/have-type')(this);
    this.type="Utility";
    setSystem.call(this, system);
    system.onEvent({
      name :     "initUtility",
      funcName : "Utility::constructor",
      lineNum  : 16
    },this.createUtility);
  }
  createUtility(){
    // Exit if this function is not invoked by pluginSystem
    this.shouldBeInvokedBy( "Framework", 'Utility.createUtility' );
    var framework=this;
    framework.utility = {
      isoDate:function(date){
        return (""+framework.utility.convertDataToDate(date).toISOString()).replace(/T/,' ').replace(/\..*$/,"");
      },
      version: updateVersion,
      formatDate:function(date){
        const month = ["January", "February", "March", "April", "May", "June","July", "August", "September", "October", "November", "December"];
        var hours = date.getHours();
        var minutes = date.getMinutes();
        var seconds = date.getSeconds();
        if(minutes < 10){
          minutes = '0' + minutes;
        }
        if(hours < 10){
          hours = '0' + hours;
        }
        if(seconds < 10){
          seconds = '0' + seconds;
        }
        var pm = hours > 11 ? 'PM' : 'AM';
        return  month[date.getMonth()] + ' ' + date.getDate() + ', ' + date.getFullYear() + ' at ' + hours + ':' + minutes + ':' + seconds + ' ' + pm;
      },
      convertDataToDate:function(data){
        let dateObj;
        if(typeof data=="undefined"){
          dateObj = new Date();
        }else {
          dateObj = new Date(data);
        }
        return dateObj;
      },
      formatQuantity: function(v, dp){
        v = new BigNumber(v.toString()).toFormat();
        if(dp != null){
          v = new BigNumber(v).toFixed(dp,3);
        }
        return v;
      },
      formatValue: function(v){
        v = new BigNumber(v.toString()).toFormat();
        v = new BigNumber(v).toFixed(0,3);
        return v;
      },
      getScheduledTime:function(initiatedTime, walletType){
        var scheduledTime;
        if(walletType == 'Frozen'){
          var oneDayLater = initiatedTime;
          oneDayLater.setTime(initiatedTime.getTime() + (24*60*60*1000));
          scheduledTime = this.formatDate(oneDayLater);
        }else if(walletType == 'Cold'){
          var sixHourLater = initiatedTime;
          sixHourLater.setTime(initiatedTime.getTime() + (4*60*60*1000));
          scheduledTime = this.formatDate(sixHourLater);
        }else{
          scheduledTime = this.formatDate(initiatedTime);
        }
        return scheduledTime;
      },
      addTime:function(originalTime, numberOfHours){
        var hoursLater = originalTime;
        hoursLater.setTime(originalTime.getTime() + (numberOfHours*60*60*1000));
        return hoursLater;
      },
      getIpAddress:function(req){
        console.log("get ip: " + req);
        try{
          let ipAddress = (req.headers['x-forwarded-for'] || '').split(',').pop() || req.connection.remoteAddress ||  req.socket.remoteAddress ||  req.connection.socket.remoteAddress;
          ipAddress = ipAddress.replace(/^.*:/, '');
          console.log("get ip: " + ipAddress);
          return ipAddress;
        }catch(err){
          framework.logger("error", "Fail to get IP address: " + err);
          return "";
        }
      },
      getLocation:async function(ipAddress){
        console.log("getting locatoin from ip " + ipAddress);
        if(typeof ipAddress == 'undefined' || ipAddress == ''){
          return "unidentified";
        }
        var url = 'https://ipinfo.io/' + ipAddress;
        var options = {
            uri: url,
            json: true
        };
        var location = '';
        try{
          await rp(options)
          .then(function (ipinfo){
            if(typeof ipinfo.country != 'undefined'){
              location = ipinfo.country;
              if(typeof ipinfo.region != 'undefined'){
                location += ' ' + ipinfo.region;
              }
              if(typeof ipinfo.city != 'undefined'){
                location += ' ' + ipinfo.city;
              }
            }else if(typeof ipinfo.bogon != 'undefined'){
              location = 'Private Network';
            }else{
              location = 'unknown';
            }
          });
        }catch(err){
          framework.logger("info", "Get Location " + err);
          return "unidentified";
        }
        return location;
      },
      getUserAgent:function(req){
        var agent = useragent.parse(req.headers['user-agent']);
        return agent.toString();
      },
      convertAssetQuantity: async function(assetTicker, quantity, toType){
        let data = await framework.knex('asset_type')
        .select(framework.knex.raw('smallest_unit as unit'))
        .where({ticker: assetTicker})
        .catch(err => {framework.logger("error", "SQL Get Asset Smallest Unit [systemUtility]" + err); throw Error('sql error').toString()});
        var unit = data[0].unit;
        if(isNaN(unit) || quantity == null){
          return quantity;
        }
        if(toType == 'integer'){
          var converted = new bigdecimal.BigDecimal(quantity.toString()).multiply(new bigdecimal.BigDecimal(Math.pow(10, Math.abs(unit)).toString())).intValue();
          return converted.toString();
        }else{
          var converted = new bigdecimal.BigDecimal(quantity.toString()).divide(new bigdecimal.BigDecimal(Math.pow(10, Math.abs(unit)).toString()) , Math.abs(unit) , bigdecimal.RoundingMode.HALF_UP() );
          return converted.toPlainString();
        }
      },
      specialCharacterDecode: function(value){
        var re = new RegExp(/(&&((?<=&&)(.*?)(?=;));)/g);
        var match = re.exec(value);
        var decoded = value;
        while (match != null) {
           decoded = decoded.replace(match[0],specialCharacterDecode[match[0]])
           match = re.exec(value);
        }
        return decoded;
      },
      verifyQuantity:function(value, maxValue){
        value = value.replace(/,/g,"");
        if(typeof maxValue != 'undefined'){
          return /^[0-9]{1,18}\.[0-9]{4}$/g.test(value) && new BigNumber(value.toString()).gt(new BigNumber("0")) && new BigNumber(value.toString()).lte(new BigNumber(maxValue.toString()));
        }else{
          return /^[0-9]{1,18}\.[0-9]{4}$/g.test(value) && new BigNumber(value.toString()).gt(new BigNumber("0"));
        }
      },
      verifyCurrency:function(value, maxValue){
        value = value.replace(/,/g,"");
        if(typeof maxValue != 'undefined'){
          return /^[0-9]{1,18}$/g.test(value) &&  new BigNumber(value.toString()).lte(new BigNumber(maxValue.toString()));
        }else{
          return /^[0-9]{1,18}$/g.test(value);
        }
      },
      calculateCurrency:function(quantity, asset){
        quantity = quantity.replace(/,/g,"");
        if(typeof global.price != 'undefined' && typeof global.price[asset] != 'undefined'){
          return new BigNumber(quantity.replace(/,/g,"")).times(new BigNumber(global.price[asset].toString())).toFixed(0,3);
        }else{
          return false;
        }
      },
      trimInputs:function(value){
        value = value.replace(/<[^>]+>/gm,'');
        return value;
      }
    }
    this.emitEvent({
      name :     "utilityInited",
      funcName : "Utility::createUtility",
      lineNum  : 187
    });
  }
}
module.exports = Utility;
