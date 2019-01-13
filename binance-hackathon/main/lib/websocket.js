'use strict';

const WebSocket = require('./util/ws/ws');

WebSocket.Server = require('./util/ws/websocket-server');
WebSocket.Receiver = require('./util/ws/receiver');
WebSocket.Sender = require('./util/ws/sender');

module.exports = WebSocket;
