const updateVersion = '0.1.1';
const updateDate  = '2018-10-31';
const appName = 'haveObjectName';

const capitalize = (word) => {
  return `${word.slice(0, 1).toUpperCase()}${word.slice(1).toLowerCase()}`
}

function haveObjectName(targetObject,objectName,typeName){
  if(typeof typeName=="string"){
    require('./have-type')(targetObject);
    targetObject.type=typeName;
    targetObject.objectName=capitalize(objectName)+capitalize(typeName);
  } else {
    targetObject.objectName=objectName;
  }
  targetObject.functionName=function(name){
    if(typeof name=="undefined"){
      return targetObject._fnName;
    }else {
      if(typeof targetObject._fnStack=='undefined'){
        targetObject._fnStack=[];
      }
      targetObject._fnName=""+name;
      targetObject._fnStack.push(targetObject._fnName);
    }
  }
  targetObject.clearFunction=function(){
    if(typeof targetObject._fnStack=='undefined'){
      targetObject._fnName="";
    }else{
      targetObject._fnName=targetObject._fnStack.pop();
    }
  }
  targetObject.codeLocation=function(){
    let location=[];
    if(typeof targetObject.objectName=="string"){
      location.push(targetObject.objectName)
    }
    location.push(targetObject.functionName());
    if(location.length==0){
      location.push('n/a');
    }
    return location.join('::');
  }

}
module.exports = haveObjectName;
