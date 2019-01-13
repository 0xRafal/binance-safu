const capitalize=require('../util/capitalize');

function haveType(object){
  Object.defineProperty(object,'type',{
    set: function (value) {
      this._type=capitalize(value);
    },
    get: function () {
      return this._type.toString();
    }
  });
  object.shouldBeInvokedBy = function(type, func){
    if(!this._type==capitalize(type)){
      if(typeof this.logger=="function"){
        this.logger("error",func.name+" was by Wrong Object type:"+type);
      }
      throw new Error(
        func.name+" was invoked by Wrong Object:"
        + type
        +", expecting: "+this.type
      );
    }
  }
  object.isType=function(name){
    return this.type.toLowerCase()==(""+name).toLowerCase();
  }
}
module.exports = haveType;
