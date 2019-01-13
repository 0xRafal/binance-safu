const https = require('https');
const http = require('http');
const WebSocket = require('./websocket');
const net = require('net');
class PubSubClient{
  constructor(option){
    this.pubSubServer = (option.pubSubServer) ? option.pubSubServer : '';
    this.channel = (option.channel)? option.channel: '/' ;
    this.authPath = (option.authPath) ? option.authPath: '';
    this.authServer = (option.authServer) ? option.authServer : '';
    this.apiKey = (option.apiKey) ? option.apiKey : '';
    this.stateFailed = false;
    this.useHTTPS = (typeof option.useHTTPS =='boolean') ? option.useHTTPS : true;
    this.authServerConnection = true;
    this.networkConnection = true;
    if(this.useHTTPS){
      this.authPort = 443;
      this.pubSubPort = 443;
    } else {
      this.authPort = 80;
      this.pubSubPort = 80;
    }
    this.authServer.replace(/^([^:]+):([\d]+)$/,(s,t,u) => {
      this.authServer = t;
      this.authPort = u;
    });
    this.pubSubServer.replace(/^([^:]+):([\d]+)$/,(s,t,u) => {
      this.pubSubServer = t;
      this.pubSubPort = u;
    });
    this.daemonized = false;
    this._onMessage = function(){};
    this._onReconnect = function(){};
    this._onEnd = function(){};
    this._onClose = function(){};
    this._onOpen = function(){};
  }
  onMessage(func){
    if(typeof func=='function'){
      this._onMessage = func;
    }
    return this;
  }
  onEnd(func){
    if(typeof func=='function'){
      this._onEnd = func;
    }
    return this;
  }
  onClose(func){
    if(typeof func=='function'){
      this._onClose = func;
    }
    return this;
  }
  onOpen(func){
    if(typeof func=='function'){
      this._onOpen = func;
    }
    return this;
  }
  onMessage(func){
    if(typeof func=='function'){
      this._onMessage = func;
    }
    return this;
  }
  onReconnect(func){
    if(typeof func=='function'){
      this._onReconnect = func;
    }
    return this;
  }
  send(msg){
    if(this.ws.readyState==1){
      this.ws.send(msg);
    }
    return this;
  }
  connectionFailed(){
    if(this.networkConnection){
      this.networkConnection = false;
      if(this.ws){
        this.ws.close();
      }
      console.log('Network connection has been [DISCONNECTED]');
    }
  }
  reconnect(){
    var client = new net.Socket();
    client.connect(this.pubSubPort, this.pubSubServer, () => {
      this.networkConnection = true;
      if(this.ws){
        this.ws.close();
      }
      this.connect(()=>{
        this._onReconnect();
        console.log('Server connection [RESUMED]');
      });
    });
    client.on('error', (err) => {
      console.log("Error in Reconnection: "+err);
      this.connectionFailed();
    });
  }
  checkState(){
    if(!this.ws || this.ws.readyState==3 ){
      if(!this.stateFailed){
        if(!this.ws){
          console.log("Error in State Checking - WebSocket [GONE]");
        } else {
          console.log("Error in State Checking - Ready State: "+this.ws.readyState);
        }
        this.stateFailed = true;
      }
      this.reconnect();
    }else {
      this.stateFailed = false;
      if (this.isPingable === false) {
        console.log('WS Ping got no response, terminating connection');
        return this.ws.terminate();
      }
      this.ws.ping('');
      this.isPingable = false;
    }
  }

  checkGoogle(){
    var googleClient = new net.Socket();
    googleClient.connect(80, 'www.google.com',() => {
      if(this.networkConnection){
        this.checkState();
      }else {
        this.reconnect();
      }
    });
    googleClient.on('error',(err) => {
      if(this.networkConnection){
        console.log("Connect to google [FAILED]!");
        this.connectionFailed();
      }
    });
  }
  daemon(){
    var self = this;
    this.daemonized = true;
    this.connect();
    setInterval(() => {this.checkGoogle()}, 5000);
    console.log("Websockets Daemon Start");
    return this;
  }
  startSocket(callBack,session){
    var sessionPara = (session) ? ['?session=',session].join('') : '';
    var protocol = (this.useHTTPS) ? 'wss://' : 'ws://';
    var port;
    if((this.useHTTPS && this.pubSubPort == 443 )||(!this.useHTTPS && this.pubSubPort == 80 )){
      port = '';
    } else {
      port = [':',this.pubSubPort].join('');
    }
    if((this.pubSubServer) && this.pubSubServer!='' && (this.channel) && this.channel!=''){
      var sockAddr=[
        protocol,
        this.pubSubServer,
        port,
        this.channel,
        sessionPara
      ].join('');
      try {
        console.log("Trying to connect to server: "+ sockAddr);
          this.ws=new WebSocket(sockAddr);
          this.ws.on('open', () => {
            if(this.ws.readyState==1){
              this.ws.send('');
              if(typeof callBack =='function'){
                callBack();
              }
              this._onOpen();
              this.isPingable = true;
            }
          });
          this.ws.on('error', (err) => {
            console.log('Cannot re');
          });
          this.ws.on('close', (data) => {
            console.log('Connection [CLOSED]');
            this._onClose(data);
          });
          this.ws.on('pong', (data) => {
            console.log('Got Pong from server');
            this.isPingable = true;
          });
          this.ws.on('message', (data) => {
            console.log(data);
            this._onMessage(data);
          });
          console.log(sockAddr+" [ESTABLISHED]!");
      }catch(err){
        console.log(err);
      }
    } else {
      if(!(this.pubSubServer) || this.pubSubServer==''){
        console.log('PubSub server [NOT SET]!');
      }
      if(!(this.channel) || this.channel==''){
        console.log('Channel name [NOT SET]!');
      }
    }
    return this;
  }
  connect(callBack){
    if((this.authServer) && this.autServer!=''){
      if(this.useHTTPS){
        this.authByHTTPS(callBack);
      }else{
        this.authByHTTP(callBack);
      }
    } else {
      this.startSocket(callBack);
    }
    return this;
  }
  getHttpOptions(){
    return {
        host: this.authServer,
        port: this.authPort,
        path: this.authPath+this.channel,
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'X-Api-Key': this.apiKey
        }
    };
  }
  authRequest(conn, callBack){
    var options = this.getHttpOptions();
    conn.get(options, (res) => {
      var body=[];
      var session={};
      res.on('data', (d) => {
        body.push(d);
      });
      res.on('end', () => {
        if(res.statusCode=='200'){
          try {
            var result=JSON.parse(body.join());
            var session = (result.session) ? result.session : '';
            this.startSocket(callBack,session);
          } catch (err){
            if(this.authServerConnection){
              console.log("Cannot Authorize! This is normal if the server is just restarted!");
              this.authServerConnection = false;
            }
          }
        }
      });
    }).on('error', (e) => {
      console.error(e);
    });
  }
  authByHTTP(callBack){
    this.authRequest(http, callBack);
  }
  authByHTTPS(callBack){
    this.authRequest(https, callBack);
  }
}
module.exports = PubSubClient;
