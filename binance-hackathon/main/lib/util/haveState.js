const updateVersion = '0.1.2';
const updateDate  = '2018-12-18';
const appName = 'haveState';
const StateMachine = require('../state-machine');
// Mixing t object with x's method
const mixin=function(t,x){let n,s,k;for(n=1;n<arguments.length;n++){s=arguments[n];for(k in s){if(s.hasOwnProperty(k)){t[k]=s[k]}}}}

function haveState(modelName, model){
  this.shouldBeInvokedBy("Model","haveState");
  let self=this;
  let stateTableField = [modelName,'status','id'].join('_');
  StateMachine.apply(self, model);
  self.loadFromDB = async function(id){
    if(typeof id == "undefined"){
      throw new Error("ID must be specified")
    }
    let state = await self.knex(modelName)
      .select(stateTableField )
      .where('id','=',id);

    if(state.length==0){
      throw {message:"Wrong ID!"}
    }else{
      let tempCode = parseInt(state[0][stateTableField]);
      for(var stateName in self.ENUM){
        if(self.ENUM[stateName] == tempCode){
          self.state = stateName;
        }
      }
    }
    return self.state
  }
  self.saveDB = async function(id){
    var state_id = this.ENUM[self.state];
    await this.knex(modelName)
    .update(stateTableField, state_id)
    .where('id','=', id);
  }
}
module.exports=haveState;
