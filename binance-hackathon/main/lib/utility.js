const updateVersion = '0.0.4';
const updateDate  = '2018-09-27';
const appName = 'Utility';

var rp = require('request-promise');
var useragent = require('useragent');

var dp=(function($,r){
  var e=[
    /^([^.]*\d)(\d{3})(\.\d+)?$/g,
    /(\d)(\d{3}),/g,
    /[^\d\.]/g,/(\.\d*)\.(000000000)/g,
    /[^\d\.]|\..*$/g,/0+$/,
    /(\d\.\d{1}).+/g,
    /(\d\.\d{2}).+/g,
    /(\d\.\d{3}).+/g,
    /(\d\.\d{4}).+/g,
    /(\d\.\d{5}).+/g,
    /(\d\.\d{6}).+/g,
    /(\d\.\d{7}).+/g,
    /(\d\.\d{8}).+/g,
    /(\d\.\d{9}).+/g];
  function t(v){
    var w,v=(""+v)[r](e[0],"$1,$2$3");
    do{
      v=(w=v)[r](e[1],"$1,$2,")
    }while(w!=v);
    return w
  }
  function f(g,v){
    var s,v=t((s=d(v))[r](e[g],$));
    return parseFloat(v)==0?""+parseFloat(s):v
  }
  function d(v){
    return(""+v+".000000000")[r](e[2],"")[r](e[3],"$1$2")
  }
  return[
    function(v){return t((""+v)[r](e[4],""))},
    function(v){return f(6,v)},
    function(v){return f(7,v)},
    function(v){return f(8,v)},
    function(v){return f(9,v)},
    function(v){return f(10,v)},
    function(v){return f(11,v)},
    function(v){return f(12,v)},
    function(v){return f(13,v)},
    function(v){return f(14,v)}
  ]
})("$1","replace"),
formatCurrency=function(v){return dp[0](v)},
formatQuantity=function(v){return dp[4](v)};

class Utility{
  constructor(){
    this.version = updateVersion;
  }

  formatDate(date){
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
  }

  convertDataToDate(data){
    var dateObj = new Date(data);
    return dateObj;
  }

  getScheduledTime(initiatedTime, walletType){
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
  }

  addTime(originalTime, numberOfHours){
    var hoursLater = originalTime;
    hoursLater.setTime(originalTime.getTime() + (numberOfHours*60*60*1000));
    return hoursLater;
  }

  getIpAddress(req){
    let ipAddress = (req.headers['x-forwarded-for'] || '').split(',').pop() || req.connection.remoteAddress ||  req.socket.remoteAddress ||  req.connection.socket.remoteAddress;
    ipAddress = ipAddress.replace(/^.*:/, '');
    return ipAddress;
  }

  async getLocation(ipAddress){
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
        location = 'unidentified';
      }
      });
    }catch(err){
      console.log("info", "Get Location " + err);
      return "unidentified";
    }
    return location;
  }

  getUserAgent(req){
    var agent = useragent.parse(req.headers['user-agent']);
    return agent.toString();
  }

  verifyQuantity(value, maxValue){
    value = value.replace(/,/g,"");
    if(typeof maxValue != 'undefined'){
      return /^[0-9]{1,18}\.[0-9]{4}$/g.test(value) && new BigNumber(value.toString()).gt(new BigNumber("0")) && new BigNumber(value.toString()).lte(new BigNumber(maxValue.toString()));
    }else{
      return /^[0-9]{1,18}\.[0-9]{4}$/g.test(value) && new BigNumber(value.toString()).gt(new BigNumber("0"));
    }
  }

  verifyCurrency(value, maxValue){
    value = value.replace(/,/g,"");
    if(typeof maxValue != 'undefined'){
      return /^[0-9]{1,18}$/g.test(value) &&  new BigNumber(value.toString()).lte(new BigNumber(maxValue.toString()));
    }else{
      return /^[0-9]{1,18}$/g.test(value);
    }
  }

  calculateCurrency(quantity, asset){
    quantity = quantity.replace(/,/g,"");
    if(typeof global.price != 'undefined' && typeof global.price[asset] != 'undefined'){
      return formatCurrency(parseFloat(quantity.replace(/,/g,""))*global.price[asset]);
    }else{
      return false;
    }
  }

  trimInputs(value){
    value = value.replace(/<[^>]+>/gm,'');
    return value;
  }
}
module.exports = Utility;
