const updateVersion = '0.1.4';
const updateDate  = '2018-12-24';
const appName = 'HexFramework';
const EventEmitter = require('events');

const fs = require('fs');
const { lstatSync, readdirSync } = fs;
const { join } = require('path');
const haveVersion = require('./util/haveVersion');
const haveObjectName = require('./util/haveObjectName');
const setSystem = require('./util/setSystem');
const Utility = require('./class/SystemUtility');
const logger = new (require('./class/Logger'))();
const PID = require('./class/PID');
const ExpressSuit = require('./class/ExpressSuit');

const getFilelist = source => readdirSync(source).map(
  name => join(source, name)
)

class HexFramework extends EventEmitter{
  constructor( pid, options ){
    super();
    this.options= options || {
      startPluginManager: true,
      startNotFoundManager: true
    }
    haveObjectName(this,"Hex","Framework");
    require('./util/have-event')(this,'constructor',29);
    let info=require('../package.json');
    global.appName=info.name;
    new Utility(this);
    new ExpressSuit(this);
    this.loadMiddleware();
    this.init( pid );
  }
  loadMiddleware(){
    let middlewareFolder =  getFilelist("./lib/middleware");
    for (let indx in middlewareFolder){
      let self=this;
      middlewareFolder[indx].replace(/^.+\/(\d+\-)([^\/]+)\.js$/,function(s,v,t){
        self[t]=new (require('./middleware/'+v+t))(self);
        self.logger("info","Middleware: "+t+" [LOADED]","constructor",43);
      })
    }
  }
  logger(mode, msg, funcName, lineNum) {
    logger.log(this,mode,msg, funcName, lineNum);
  }

  init( pid ){
    haveVersion.call(this,appName,updateVersion,updateDate);
    new PID( this, pid );
    this.onEvent({
        name :     "utilityInited",
        funcName : "init",
        lineNum  : 54
      },function(){
      this.emitEvent({
        name :     "initPID",
        funcName : "init",
        lineNum  : 59
      });
    })
    this.onEvent({
      name :     'pidInited',
      funcName : "init",
      lineNum  : 65
    },function(){
      this.emitEvent({
        name :     "welcome",
        funcName : "init",
        lineNum  : 73
      });
      this.emitEvent({
        name :     "startListener",
        funcName : "init",
        lineNum  : 75
      });
    });
    this.onEvent({
      name :     'listenerStarted',
      funcName : "init",
      lineNum  : 81
    },function(){
      if(this.options.startPluginManager){
        this.PluginManager.start();
      }
      if(this.options.startNotFoundManager){
        this.NotFoundManager.start();
      }
      this.emitEvent({
        name :     "inited",
        funcName : "init",
        lineNum  : 93
      });
    });
    this.emitEvent({
      name :     "initUtility",
      funcName : "init",
      lineNum  : 99
    });
  }
}
module.exports = HexFramework;
