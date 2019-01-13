const modelName = 'addressPlugin';
const model = {};
class Model{
  constructor(pluginSystem){
    pluginSystem.addModel(this,modelName,model);
  }
}
module.exports=Model
