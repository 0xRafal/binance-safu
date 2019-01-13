class Service {
  constructor(model) {
    model.addService(this);
    this.system.onEvent({
      name :     "inited",
      funcName : "BlankPlugin::Service::constructor",
      lineNum  : 4
    }, this.testEvent.bind(this));
  }
  testEvent(value){
    this.logger("info",
      "value from caller:"+value,
      "testEvent",
    12);
  }
}
module.exports = Service;
