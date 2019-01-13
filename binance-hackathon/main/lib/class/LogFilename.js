const fs = require("fs");
const ModeMap={
  "undefined": "",
  "cronjob": "log/cronjob/cronjob-",
  "not-found": "log/security/not-found-",
  "login": "log/security/login-",
  "security": "log/security/security-",
  "event": "log/debug/event-",
  "debug": "log/debug/info-",
  "info": "log/debug/info-",
  "error": "log/error/error-",
  "sql": "log/sql/sql-",
};

class LogFilename{
  constructor(){
    Object.defineProperty(this,'mode',{
      set: function (value) {
        if(typeof ModeMap[value.toLowerCase()]!="undefined"){
          this._mode=value.toLowerCase();
        }
      },
      get: function () {
        return this._mode;
      }
    });
    Object.defineProperty(this,'filename',{
      set: function (value) {
        if(typeof this.logger=="function"){
          this.logger("error","property filename cannot be assigned directly.");
        }
        throw new Error(
          "property filename cannot be assigned directly."
        );
      },
      get: function () {
        var filename='';
        if(typeof ModeMap[this._mode]!="undefined"){
          if(this._mode=="info" || this._mode=="debug"){
            filename=[ModeMap[this._mode],this.hourlyLog()].join('');
          }else{
            filename=[ModeMap[this._mode],this.dailyLog()].join('');
          }
        }
        return filename;
      }
    });
  }
  toString(){
    return this.filename  ;
  }
  dailyLog(){
    return [this.now().replace(/\s.+$/g,""),'.log'].join('');
  }
  hourlyLog(){
    return [this.now().replace(/:.+$/g,"").replace(/\s+/g,"-"),'.log'].join('');
  }
  now(){
    return (new Date()).toISOString().replace(/T/,' ').replace(/\..*$/,"");
  }
}
module.exports=LogFilename;
