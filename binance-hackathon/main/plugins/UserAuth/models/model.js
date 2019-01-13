const crypto = require('crypto');

const modelName = 'auth';

const model = {
  transitions:[
    {name: 'verify', from: 'none', to : 'activated'},
    {name: 'deactive', from: 'activated', to: 'deactived'},
    {name: 'active', from: 'deactived', to: 'actived'},
    {name: 'lock', from: 'activated', to: 'locked'},
    {name: 'unlock', from: 'locked', to: 'activated'},
    {name: 'suspend', from: 'activated', to: 'suspended'},
    {name: 'unsuspend', from: 'suspended', to: 'activated'},
    {name: 'delete', from: 'deactived', to: 'deleted'}
  ],
  methods: {
  }
};
class Model{
  constructor(pluginSystem){
    pluginSystem.addModel(this,modelName,model);
  }
}

module.exports=Model
