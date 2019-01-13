const fs = require("fs");
const LogFilename=require('./LogFilename');
const camelize=require('../util/camelize');
require('dotenv').config();
class Logger extends LogFilename{
  constructor(){
    super();
    if(typeof global.loggerInited!='undefined'){
      return this;
    }
    this.mode="cronjob";
    this.logRaw(this.filename,  this.startMessage());
    this.mode="not-found";
    this.logRaw(this.filename,  this.startMessage());
    this.mode="login";
    this.logRaw(this.filename,  this.startMessage());
    this.mode="security";
    this.logRaw(this.filename,  this.startMessage());
    this.mode="event";
    this.logRaw(this.filename,  this.startMessage());
    this.mode="info";
    this.logRaw(this.filename,  this.startMessage());
    this.mode="info";
    this.logRaw(this.filename,  this.startMessage());
    this.mode="sql";
    this.logRaw(this.filename,  this.startMessage());
    global.loggerInited=true;
  }
  startMessage(){
    return ["===",camelize(this.mode)," Log Started","===",'\n'].join(' ');
  }
  logMessage(target, msg){
    let logMsg=[this.now(),' @',this.mode];
    if(this.mode=='not-found'){
      logMsg.push(':> ', msg,'\n');
      return logMsg.join('');
    }
    logMsg.push(' [');
    let location=[];
    if(typeof target.codeLocation=="function"){
      location.push(target.codeLocation());
    }
    if(location.length==0){
      location.push('N/A');
    }else {
      if(this.funcName!=''){
        location.push('(',this.funcName,')');
        if(this.lineNum!=''){
          location.push(':',this.lineNum);
        }
      } else {
        location.push('(Unknown_Function)');
      }
    }
    logMsg.push(location.join(''));
    logMsg.push(']:> ', msg,'\n');
    return logMsg.join('');
  }
  logRaw (filename,message){
    fs.appendFile(filename,  message, function (err) {
        if (err) throw err;
    });
  }
  log( target, mode, msg,funcName, lineNum ){
    this.mode=mode;
    if(typeof funcName=='string'){
      this.funcName=funcName;
    }else{
      this.funcName='';
    }
    if(typeof lineNum!='undefined'){
      this.lineNum=lineNum;
    }else{
      this.lineNum='*';
    }
    var message=this.logMessage(target, msg);
    if( mode!="info" && mode!="debug"){
      this.logRaw(this.filename,  message);
    }
    this.mode="info";
    if(typeof process.env.NODE_ENV=='string' &&
      process.env.NODE_ENV=='development'){
      console.log(message);
    }
    this.logRaw(this.filename,  message);
  }
}

module.exports = Logger;
