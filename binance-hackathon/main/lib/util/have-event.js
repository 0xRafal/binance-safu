function haveEvent(object,funcName,lineNum){
  if(typeof object.logger=="function"){
    var funcName = typeof funcName == 'string' ? funcName : 'Unknown_Function';
    var lineNum = typeof lineNum != 'undefined' ? lineNum : '';
    object.logger("info","Event for "+object.type+" [SET]",funcName,lineNum);
  }
  if(object.isType('Framework')){
    object.emitEvent=function( ){
      var funcName='Unknown_Function';
      var lineNum = '*';
      var name = '';
      if(typeof arguments[0]=="object"){
        funcName = arguments[0].funcName;
        lineNum = arguments[0].lineNum;
        name = arguments[0].name;
      }else{
        name = arguments[0];
      }
      if(typeof this.logger=="function"){
        this.logger("event",name+" [Emited]",funcName, lineNum);
      }
      if(arguments[1]){
        this.emit(name,arguments[1]);
      }else{
        this.emit(name);
      }
    }
    object.onEvent=function(){
      var funcName='Unknown_Function';
      var lineNum = '*';
      var name = '';
      if(typeof arguments[0]=="object"){
        funcName = arguments[0].funcName;
        lineNum = arguments[0].lineNum;
        name = arguments[0].name;
      }else{
        name = arguments[0];
      }
      let func=arguments[1];
      let self=this;
      this.on.apply(this,[name,function(){
        if(typeof self.logger=="function"){
          self.logger('event',name+" [Received]",funcName, lineNum);
        }
        func.apply(self,arguments);
      }]);
    }
  }else {
    object.emitEvent=function( ){
      var funcName='Unknown_Function';
      var lineNum = '*';
      var name = '';
      if(typeof arguments[0]=="object"){
        funcName = arguments[0].funcName;
        lineNum = arguments[0].lineNum;
        name = arguments[0].name;
      }else{
        name = arguments[0];
      }

      if(typeof this.logger=="function"){
        this.logger("event",name+" [Emited]",funcName, lineNum);
      }
      if(arguments[1]){
        let msg=arguments[1];
        this.system.emit(name,msg);
      }else{
        this.system.emit(name);
      }
    }
    object.onEvent=function(){
      var funcName='Unknown_Function';
      var lineNum = '*';
      var name = '';
      if(typeof arguments[0]=="object"){
        funcName = arguments[0].funcName;
        lineNum = arguments[0].lineNum;
        name = arguments[0].name;
      }else{
        name = arguments[0];
      }
      let func=arguments[1];
      let self=this;
      this.system.on.apply(this,[name,function(){
        if(typeof self.logger=="function"){
          self.logger('event',name+" [Received]",funcName, lineNum);
        }
        func.apply(self,arguments);
      }]);
    }
  }
}
module.exports = haveEvent;
