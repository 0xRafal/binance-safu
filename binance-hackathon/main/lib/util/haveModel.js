const updateVersion = '0.1.4';
const updateDate  = '2018-12-24';
const appName = 'haveModel';
const haveState = require('./haveState');
const haveObjectName = require('./haveObjectName');
const haveEvent = require('./have-event');
const setSystem = require('./setSystem');
const logger = new (require('../class/Logger'))();

function haveModel(){
  this.addModel=function(self, modelName, model){
    self.modelName=modelName;
    self.logger=function(mode, msg, funcName, lineNum) {
      logger.log(this, mode,msg, funcName, lineNum);
    }
    if(typeof this.system !="undefined" && typeof this.system.type=="string" && this.system.type=="Framework"){
      setSystem.call( self, this.system ) ;
      haveObjectName(self,this.system.currentName,"Model");
    }else if(typeof typeof this.type=="string" && this.type=="Framework"){
      setSystem.call( self, this ) ;
      haveObjectName(self,this.currentName,"Model");
    }
    haveEvent(self, "haveModel::addModel", 23);
    self.getSchema=async function(table){
      let result= await this.knex.raw(['desc ',table].join(''));
      let schema = [];
      for(let j in result[0]){
        for(let k in result[0][j]){
          if(""+k=="Field"){
            schema.push(result[0][j][k])
          }
        }
      }
      return schema;
    }
    self.addService=function(target){
      target.model=self;
      setSystem.call( target, this.system ) ;
      target.logger=function(mode, msg, funcName, lineNum) {
        logger.log(this,mode,msg, funcName, lineNum);
      }
      haveObjectName(target,this.system.currentName,"Service");
      haveEvent(target, "haveModel::addService", 43);
      target.addRouter=function(object){
        object.service=target;
        object.logger=function(mode, msg, funcName, lineNum) {
          logger.log(this,mode,msg, funcName, lineNum);
        }
        haveObjectName(object,this.system.currentName,"Router");
        setSystem.call( object, this.system ) ;
        haveEvent(object, "haveModel::addService", 51);
        object.Router = this.Router
        object.setRouter=function(route){
          this.clearFunction("setRouter");
          this.system.addRouter(route,object.router())
        }
      }
    }

    // some how the original object defineProperty failed
    // we need to define again. And we try to change to access _state directly
    haveState.call(self,modelName, model);
  }

}
module.exports=haveModel;
