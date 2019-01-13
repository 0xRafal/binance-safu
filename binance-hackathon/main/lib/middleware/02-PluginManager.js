const updateVersion = '0.1.6';
const updateDate  = '2018-11-5';
const appName = 'PluginManager';
const fs = require('fs');
const { lstatSync, readdirSync } = fs;
const { join } = require('path');
const setSystem = require('../util/setSystem');
const haveModel = require('../util/haveModel');
const haveObjectName = require('../util/haveObjectName');
const logger = new (require('../class/Logger'))();
const isDirectory = source => lstatSync(source).isDirectory()
const getDirectories = source => readdirSync(source).map(
  name => join(source, name)
).filter(isDirectory)

class PluginManager {
  constructor(system){
    haveObjectName(this,"Hex","PluginManager");
    setSystem.call( this, system);
    haveModel.call(this);
    system.addModel=this.addModel;
    system.preparePlugin=this.preparePlugin;
    system.loadPlugin=this.loadPlugin;
  }
  logger(mode, msg, funcName, lineNum) {
    logger.log(this, mode, msg, funcName, lineNum);
  }
  loadPlugin(plugin,pluginName){
    let system;
    if(typeof this.system=="undefined"){
      system=this;
    }else{
      system=this.system;
    }
    let pluginPath=plugin.replace(/\/(\.\.\/)+/g,'');
    system.currentName=pluginName;
    let loadedPlugin=new (require('../../'+pluginPath))(this);
    haveObjectName(loadedPlugin,pluginName,"Plugin");
    return loadedPlugin;
  }
  preparePlugin(plugin, path, pluginName){
    let loadedPlugin={};
    try{
      if(fs.existsSync(plugin)){
        try{
          this.logger("info",pluginName+" [EXISTS]","preparePlugin",46)
          loadedPlugin=this.loadPlugin(plugin,pluginName);
        }catch(err){
          this.logger("error",err,"preparePlugin",49);
          loadedPlugin.success = false
        }
        if(typeof loadedPlugin.success=='boolean' && !loadedPlugin.success){
          this.logger("error",[
            pluginName, " - loading code [failed]"
          ].join(''), "preparePlugin",53);
        }
      }
    }catch(err){
      this.logger("error",err,"preparePlugin",59);
    }
    return loadedPlugin;
  }
  start(){
    let pluginFolder =  getDirectories("./plugins");
    for (let indx in pluginFolder){
      let self=this;
      pluginFolder[indx].replace(/^.+\/([^\/]+)$/,function(s,t){
        let genericPlugin=['./',s,'/plugin.js'].join('');
        self.preparePlugin( genericPlugin, s, t );
        self.logger("info","Plugins: "+t+" [LOADED]","start",70);
      })
    }
  }
}
module.exports=PluginManager;
