const updateVersion = '0.1.5';
const updateDate  = '2018-11-1';
const appName = 'setSystem';

require('dotenv').config();
const NODE_ENV = (process.env.NODE_ENV || 'development').toLocaleLowerCase();

function setSystem(system){
  if(typeof system=="undefined" || typeof system.type=="undefined" || system.type!="Framework"){
    console.log(system.type);
    throw new Error("Framework is [UNDEFINED]!")
  }
  this.system=system;
  if(typeof system.on!="function" || typeof system.emit!="function"){
    throw new Error("Framework rely on event. But event is [NOT FOUND]!")
  }

  this.checkGlobal=system.checkGlobal;

  if(typeof system.logger=="function"){
    this.logger=system.logger;
  }

  if(typeof system.env != "function"){
    system.env=function(name){
      return process.env[name];
    }
  }
  this.env=system.env;
  if(typeof system.checkEnv!="function"){
    system.checkEnv=function(names){
      let result = true;
      if(typeof names=="string"){
        if(typeof process.env[names] == "undefined"){
          result = false;
          this.logger("error", ["Environment variables: ", names,
           " [Not Found]"].join(''))
        }
      }
      else if (typeof names.length=="number"){
        for(let name in names){
          if(typeof process.env[names[name]] == "undefined"){
            result = false;
            this.logger("error", ["Environment variables: ", names[name],
              " [Not Found]"].join(''))
          }
        }
      }
      return result
    }
  }
  this.checkEnv=system.checkEnv;
  if(typeof system.Router=="function"){
    this.Router=system.Router;
  }
}
module.exports = setSystem;
