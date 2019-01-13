const crypto = require('crypto');
const rp = require('request-promise');
const userData = require('../../JsonData/user.json');

class Service {
  constructor(model) {
    model.addService(this);
    if(typeof global.authService=="undefined"){
      global.authService = this;
    }
  }

  async storeLogin(req){
    if(typeof req.body.username=="string" && typeof req.body.password=="string"){
      req.session.username = req.body.username;
      req.session.password = req.body.password;
      return true
    }
    console.log("Username or password failed: " +
      req.body.username +
      "/" +
      req.body.password
    );
    return false
  }

  async loginUser(req,res){
    let isCorrectLogin = await this.checkPassword(req);
    if(!isCorrectLogin){
      return {"login" : false}
    }
    this.setLoginSuccess(req);
    return {"login":true};
  }
  
  async loginStatus(req,res){
    if(this.isLogin(req)){
      return {"login":true, "userId":req.session.user_id}
    }
    return {"login":false}
  }

  async logOut(req){
    var logHead =  "user-" + req.session.user_id + " POST Auth-LogOut ";
    this.logger("info",logHead + "START");
    if(typeof req.session.user_id !="undefined"){
      const user_id = req.session.user_id
      delete req.session.user_id
      this.logger("info",logHead + "SUCCESS");
      return true
    }
    return false
  }

  async checkPassword(req){
    if (userData[req.session.username]['password'] == req.session.password) {
      return true;
    }
    return false;
  }

  async setLoginSuccess(req, userId){
    if(typeof req.session.username=="string" && typeof req.session.password=="string"){
      delete req.session.username;
      delete req.session.password;
    }
    req.session.user_id = userId;
  }

  async isLogin(req){
    let result = (typeof req.session=="object"
      && typeof req.session.username!="undefined");
    return result
  }
  
}
module.exports = Service;
