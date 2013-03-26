(function () {
  'use strict';

  // socketIO adapter

  var socketIOAdapter = new hammer.messageAdapterConstructor();

  socketIOAdapter.setup = function (after_setup_callback) {
    this.socket = io.connect(hammer.websocketUrl);
    this.socket.on('message', this.receiveCallback());
    after_setup_callback();
  };

  socketIOAdapter.send = function (message) {
    this.socket.emit('message', message);
  };

  hammer.messageAdapter = socketIOAdapter;

}());
