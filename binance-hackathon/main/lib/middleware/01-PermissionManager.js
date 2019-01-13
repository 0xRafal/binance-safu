const logger = new (require('../class/Logger'))();
const setSystem = require('../util/setSystem');
class PermissionManager{
  constructor(system){
    this.system=system;
    setSystem.call( this, system);
  }
  logger(mode, msg, funcName) {
    logger.log(this,mode,msg, funcName);
  }
}
module.exports=PermissionManager;
