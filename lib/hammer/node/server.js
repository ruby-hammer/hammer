var hammer = (function () {
  "use strict";

  var io = require('socket.io');
  var util = require('util');
//  var net = require('net');
  var path = require('path');
  var express = require('express');
  var connect = require('connect');
  var zmq = require('zmq');

  var argv = require('optimist')
      .options('host', {
        'default': '127.0.0.1',
        demand: true,
        describe: 'Host'
      })
      .options('port', {
        'default': '3000',
        demand: true,
        describe: 'Port'
      })
      .options('push', {
        'default': 'tcp://127.0.0.1:4211',
        demand: true,
        describe: 'Push channel to ruby'
      })
      .options('pull', {
        'default': 'tcp://127.0.0.1:4210',
        demand: true,
        describe: 'Pull channel to ruby'
      })
      .option('files', {
        demand: true,
        describe: "Path to public files"
      })
      .option('logTraffic', {
        'default': false,
        boolean: true,
        describe: "Log communication"
      })
      .usage("node server.js -h 127.0.0.1 -p 8080 -c /tmp/hammer.sock")
      .argv;

  function pp(object) {
    console.log(util.inspect(object));
  }

  // redirect stderr to stdout
  //process.__defineGetter__('stderr', function () {
  //  process.stdout;
  //});

  var hammer = {
    setupRubyServer: function () {
      var that = this;

      this.pushSocket = zmq.socket('push');
      this.pushSocket.bindSync(argv.push);

      this.sendToRubyWithCallback({ type: 'clientHtml' }, function (message) {
        that.clientHtml = message.clientHtml;
        that.listenClients();
      });

      this.pullSocket = zmq.socket('pull');
      this.pullSocket.connect(argv.pull);
      this.pullSocket.on('message', this.receiveFromRuby.bind(this));
    },

    sendToRuby: function (message) {
      if (argv.logTraffic) {
        console.log('hammer << ' + util.inspect(message));
      }
      hammer.pushSocket.send(JSON.stringify(message));
    },

    sendToRubyWithCallback: function (message, callback) {
      this.callbacks.set(message, callback);
      this.sendToRuby(message);
    },

    callbacks: {
      lastId: 0,
      callbacks: {},
      getId: function () {
        return (this.lastId += 1);
      },
      set: function (message, callback) {
        var id = this.getId();
        message.callbackId = id;
        this.callbacks[id] = callback;
      },
      run: function (message) {
        this.callbacks[message.callbackId](message);
        delete this.callbacks[message.callbackId];
      }
    },

    receiveFromRuby: function (json) {
      var parsed_message = JSON.parse(json.toString()); // TODO catch parse errors
      if (argv.logTraffic) {
        console.log("hammer >> " + util.inspect(parsed_message));
      }

      if (parsed_message.callbackId) {
        this.callbacks.run(parsed_message);
      } else {
        this.sendToClient(parsed_message);
      }
    },

    setupWebServer: function () {
      var that = this;
      this.webServer = express.createServer();
      this.webServer.configure(function () {
        that.webServer.use(express['static'](argv.files));
        that.webServer.use(express.cookieParser());
        that.webServer.use(express.session({ secret: "lahsdoqweoqwoelakhdashdasd", key: 'sessionId' }));
      });

      this.webServer.get('/', function (req, res) {
        console.log("client >> wants client html");
        // req.sessionID;
        // FIXME keep session id, it is changed after reload, i do not want that
        req.session.test = true;
        res.end(that.clientHtml);
      });
    },

    setupIoServer: function () {
      var that = this;
      this.ioServer = io.listen(this.webServer, {'log level': 2});
      this.ioServer.sockets.on('connection', function (socket) {
        socket.on('message', function (message) {
          that.receiveFromClient(socket, message);
        });
//        socket.on('disconnect', function () {});
      });

      // from http://www.danielbaulig.de/socket-ioexpress/
      var parseCookie = connect.utils.parseCookie;
      this.ioServer.set('authorization', function (data, accept) {
        // check if there's a cookie header
        if (data.headers.cookie) {
          // if there is, parse the cookie
          var cookie = parseCookie(data.headers.cookie);
          // note that you will need to use the same key to grad the
          // session id, as you specified in the Express setup.
          data.sessionID = cookie.sessionId;
//    pp(data.sessionID);
          return accept(null, true);
        } else {
          // if there isn't, turn down the connection with a message
          // and leave the function.
          return accept('No cookie transmitted.', false);
        }
      });
    },

    sendToClient: function (message) {
      if (argv.logTraffic) {
        console.log('client << ' + util.inspect(message));
      }
      var socket = this.ioServer.sockets.socket(message.connectionId);
      delete message.connectionId;
      delete message.containerId;
      socket.emit('message', message);
    },


    receiveFromClient: function (socket, message) {
      if (argv.logTraffic) {
        console.log('client >> ' + util.inspect(message));
      }
      message.connectionId = socket.id;
      message.containerId = socket.handshake.sessionID;
      this.sendToRuby(message);
    },

    listenClients: function () {
      this.webServer.listen(argv.port);
      console.info('listening to clients');
    },

    stopListeningClinets: function () {
      this.webServer.close();
      console.info('stopping listening to clients');
    },

    run: function () {
      console.info(argv);

      this.setupRubyServer();
      this.setupWebServer();
      this.setupIoServer();
    }
  };

  hammer.run();
  return hammer;
}());