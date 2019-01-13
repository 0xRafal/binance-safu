class Plugin{
  constructor(pluginSystem){
    this.model = new (require('./models/model'))(pluginSystem);
    this.service = new (require('./services/service'))(this.model);
    this.router = new (require('./routers/router'))(this.service);
    this.router.setRouter('/api/v1/address');
  }
}
module.exports = Plugin;
