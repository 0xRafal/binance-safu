const updateVersion = '0.1.2';
const updateDate  = '2018-10-31';
const appName = 'haveVersion';
const fs = require('fs');

function haveVersion(appName,updateVersion,updateDate){
  this.version=updateVersion;
  this.name=appName;
  this.update=updateDate;
  this.checkGlobal=function(){
    if(typeof global.plugins == "undefined"){
      global.plugins = { appName: 'Unknown-app'}
    }
  }
  this.welcome=function() {
    // Exit if this function is not invoked by pluginSystem
    this.shouldBeInvokedBy( "Framework", 'welcome' );
    this.appInfo();
    if(typeof this.emitEvent=="function"){
      this.emitEvent({
        name :     "welcomed",
        funcName : "haveVersion::welcome",
        lineNum  : 20
      });
    }
  }
  this.appInfo=function(){
    let appInfo="../../package.json";
    if (fs.existsSync(appInfo)) {
      let info=require('.'+appInfo);
      this.checkGlobal();
      global.appName = (typeof info.name == "string") ?
        info.name : "Unknown-Plugin";
      global.appVersion = (typeof info.version == "string") ?
        info.version : "?";
      global.appAuthor = (typeof info.author == "string") ?
        info.author : "Anonymous";
      global.appDate = (typeof info.update == "string") ?
        [" (", info.update, ") "].join('') : "";
      let msg=[
        global.appName ,
        " - Version: ",global.appVersion,
        global.appDate,
        " by ", global.appAuthor, " [started]"
      ].join('');
      if(typeof this.logger=="function"){
        this.logger('info',msg,"haveVersion::appInfo",68);
      }
    }
  }
  if(typeof this.onEvent=="function"){
    this.onEvent({
      name :     "welcome",
      funcName : "haveVersion",
      lineNum  : 51
    }, this.welcome);
  } else {
    if(typeof this.logger=="function"){
      this.logger("error","Problem register the onEvent!");
    } else {
      console.log("Problem register the onEvent!");
    }
  }
}

module.exports = haveVersion;
