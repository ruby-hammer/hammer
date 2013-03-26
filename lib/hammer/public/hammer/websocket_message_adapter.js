(function () {
  'use strict';

  // socketIO adapter

  var webSocketAdapter = new hammer.messageAdapterConstructor();

  webSocketAdapter.setup = function (after_setup_callback) {
    this.socket = new WebSocket(hammer.websocketUrl);
    this.socket.onopen = function () {
      after_setup_callback();
    };
    this.socket.onmessage = function (message_event) {
      webSocketAdapter.receiveCallback()(JSON.parse(message_event.data));
    };
  }

  webSocketAdapter.send = function (message) {
    this.socket.send(JSON.stringify(message));
  };

  hammer.messageAdapter = webSocketAdapter;

}());
