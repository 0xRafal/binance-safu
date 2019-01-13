const modelName = 'blankPlugin';
const model = {};
class Model{
  constructor(pluginSystem){
    pluginSystem.addModel(this,modelName,model);
  }

  async testData() {
    return await this.pipelineKnex('hourly_tx_data')
      .insert({
        'asset_id': 'ETH'
      });
  }
}
module.exports=Model
