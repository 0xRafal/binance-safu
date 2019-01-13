const updateVersion = '0.1.5';
const updateDate  = '2018-11-2';
const appName = 'ExpressSuit';
const express = require('express');
const session = require('express-session');
const logger = new (require('./Logger'))();
const haveObjectName = require('../util/haveObjectName');
const setSystem = require('../util/setSystem');
var listener={};
var socketMap = {};
var lastSocketKey = 0;
function flush(){
  // Exit if this function is not invoked by pluginSystem
  Object.keys(socketMap).forEach(function(socketKey){
    socketMap[socketKey].destroy();
  });
}

class ExpressSuit{
  constructor( system ){
    haveObjectName(this,"Hex","ExpressSuit");
    this.functionName("constructor");
    setSystem.call( this, system) ;
    system._app = express();
    system.use=function(){
      this._app.use.apply(this._app,arguments);
    }
    system.use((require('body-parser')).json({limit: '30mb'}));
    system.use(session({
      secret: 'lovely-keyboard-cat',
      resave: false,
      saveUninitialized: true
    }));
    system.Router=function(){
      return express.Router()
    }
    system.addRouter=function(path,router){
      this._app.use(path,router)
    }
    system.app=function(){
      return this._app
    }
    system.server=function(){
      if(typeof this._server=="undefined"){
        this._server = (require('http')).Server(this._app)
      }
      return this._server
    }

    let server=this;
    process.once('SIGTERM', function(){
      server.stop.call();
    });
    process.once('SIGINT', function(){
      server.stop.call();
    });
    system.onEvent({
      name :     'startListener',
      funcName : "ExpressSuit::constructor",
      lineNum  : 57
    },this.listen);
    system.stop=this.stop;
    system.flush=flush;

    this.clearFunction();
  }
  logger(mode, msg, funcName) {
    logger.log(this,mode,msg, funcName);
  }
  listen(){
    let self=this;
    this.functionName("listen");
    // Exit if this function is not invoked by pluginSystem
    this.shouldBeInvokedBy( "Framework", 'ExpressSuit.listen' );
    this.PORT = process.env.PORT || 3000;
    listener=this.server().listen(this.PORT,
      function(){
        console.log(global.appName+' - server at port '+self.PORT+' [listened]');
      }
    )
    listener.on('connection', function(socket) {
      /* generate a new, unique socket-key */
      self.emitEvent({
        name :     "socketOpen",
        funcName : "ExpressSuit::listen",
        lineNum  : 83
      });
      var socketKey = ++lastSocketKey;
      /* add socket when it is connected */
      socketMap[socketKey] = socket;
      socket.on('close', function() {
        /* remove socket when it is closed */
        self.emitEvent({
          name :     "socketClosed",
          funcName : "ExpressSuit::listen",
          lineNum  : 93
        });
        delete socketMap[socketKey];
      });
    });
    this.emitEvent({
      name :     'listenerStarted',
      funcName : "ExpressSuit::listen",
      lineNum  : 101
    });
    this.clearFunction();
  }
  stop(){
    // Exit if this function is not invoked by pluginSystem
    flush();
    let express_self=this;
    /* after all the sockets are destroyed, we may close the server! */
    listener.close(function(err){
      if(err) throw err();
      if(typeof express_self=="object" && typeof express_self.system != "undefined" && typeof express_self.system.emitEvent=="function"){
        express_self.system.emitEvent({
          name :     "serverStopped",
          funcName : "ExpressSuit::stop",
          lineNum  : 116
        });
      } else if(typeof express_self=="object" &&  typeof express_self.emitEvent=="function"){
        express_self.emitEvent({
          name :     "serverStopped",
          funcName : "ExpressSuit::stop",
          lineNum  : 122
        });
      }
      /* exit gracefully */
      //process.exit(0);
    });
  }
}

module.exports=ExpressSuit;
