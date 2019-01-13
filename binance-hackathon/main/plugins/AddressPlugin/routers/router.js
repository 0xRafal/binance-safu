class Router {
  constructor(service){
    service.addRouter(this);
  }
  router() {
    let router = this.Router();
    router.get ('/get-score', this.getAddressScore.bind(this));
    router.post ('/submit-address-score', this.submitAddressRequest.bind(this));
    router.get('/get-address-data', this.getAddressTxData.bind(this));
    return router;
  }

  getAddressScore(req, res){
    console.log('enter');
    return this.service.getAddressScore(req)
    .then( result => res.status(200).json(result))
    .catch( err => res.status(500).json({status:500,error:err}) )
  }

  getAddressTxData(req, res){
    console.log('enter getAddressTxData');
    return this.service.getAddressTxData(req)
    .then( result => res.status(200).json(result))
    .catch( err => res.status(500).json({status:500,error:err}) )
  }

  submitAddressRequest(req, res){
    return this.service.submitAddressRequest(req)
    .then( result => res.status(200).json(result))
    .catch( err => res.status(500).json({status:500,error:err}) )
  }

}
module.exports = Router;
