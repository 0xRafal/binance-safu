const logger = new (require('../class/Logger'))();
class NotFoundManager{
  constructor(system){
    this.system=system;
  }
  logger(mode, msg, funcName, lineNum) {
    logger.log(this,mode,msg, funcName, lineNum);
  }
  start(){
    this.system.use('*', (req,res) => {
      if(req.originalUrl!="/favicon.ico"){
        let ip=this.system.utility.getIpAddress(req);
        let userAgent='"'+(""+req.headers['user-agent']).replace(/"/g,"&quote;").replace(/\s+/," ")+'"';
        this.logger('not-found',
          [ip,req.method,req.originalUrl,userAgent ].join(' ')
          ,"NotFoundManager::start",14
        );
      }
      res.status(404).json({status:404});
    });
  }
}
module.exports=NotFoundManager;
