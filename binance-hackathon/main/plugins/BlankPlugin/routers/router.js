class Router {
  constructor(service){
    service.addRouter(this);
  }
  router() {
    let router = this.Router();

    router.get ('/', this.getTestRouter.bind(this));
    router.post ('/', this.postTestRouter.bind(this));

    return router
  }

  getTestRouter(req, res){
    return res.status(200).json({status: 200})
  }

  postTestRouter(req, res){
    return res.status(200).json({status: 300})
  }
}
module.exports = Router;
