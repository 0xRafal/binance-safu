const updateVersion = '0.1.4';
const updateDate  = '2018-12-24';
const appName = 'PID';
const fs = require('fs');
const setSystem = require('../util/setSystem');

class PID {
  constructor( system, pid ){
    require('../util/have-type')(this);
    this.type="PID";
    setSystem.call( this, system) ;
    // If no pid specified in parameter, "plugin" will be used
    // After that a file called "plugin.pid" will be generated to hold the pid
    if( typeof pid=="undefined" || pid == ''){
      pid="plugin";
    }
    system.pid = pid;
    system.onEvent({
      name :     'initPID',
      funcName : "PID::constructor",
      lineNum  : 18
    }
    , this.createFile);
  }
  createFile(){
    // Exit if this function is not invoked by pluginSystem
    this.shouldBeInvokedBy( "Framework", 'PID.createFile' );
    try {
      let pidName=['./',this.pid,'.pid'].join('');
      if (fs.existsSync(pidName)){
        fs.unlinkSync(pidName);
      }

      var pid = Buffer.from(process.pid + '\n');
      var fd = fs.openSync(pidName,'w');
      var offset = 0;
      this.logger("info","pid: "+pid,"PID::createFile",37);
      while (offset < pid.length) {
        offset += fs.writeSync(fd, pid, offset, pid.length - offset);
      }

      fs.closeSync(fd);
      this.logger("info","pid file: "+pidName,"PID::createFile",43);
      process.on('exit', function(){
        try {
          fs.unlinkSync(pidName);
          return true;
        } catch (pidName) {
          return false;
        }
      });

    } catch (err) {
      this.logger( "error:",err );
    }
    this.emitEvent({
      name :     'pidInited',
      funcName : "PID::createFile",
      lineNum  : 59
    });
  }
}

module.exports=PID;
