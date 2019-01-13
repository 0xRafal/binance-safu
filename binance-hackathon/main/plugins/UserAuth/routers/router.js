const crypto = require('crypto');

class Router {
  constructor(service){
    service.addRouter(this)
  }

  router() {
    let router = this.Router();
    router.post('/login', this.loginUser.bind(this));
    router.get('/logout', this.logout.bind(this));
    router.get('/status', this.loginStatus.bind(this));
    return router;
  }

  loginUser(req, res){
    return this.service.loginUser(req)
    .then( result => res.status(200).json(result))
    .catch( err => res.status(500).json({status:500,error:err}) )
  }

  logout(req, res){
    return this.service.logOut(req)
    .then( result => res.status(200).json(result))
    .catch( err => res.status(500).json({status:500,error:err}) )
  }

  loginStatus(req, res){
    return this.service.loginStatus(req)
    .then( result => res.status(200).json(result))
    .catch( err => res.status(500).json({status:500,error:err}) )
  }
}

module.exports = Router;
