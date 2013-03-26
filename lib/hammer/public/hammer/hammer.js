var hammer = (function () {
  'use strict';

  // Abstract adapter

  function MessageAdapter() {
  }

  MessageAdapter.prototype.receiveCallback = function () {
    return hammer.receive.bind(hammer);
  };

  MessageAdapter.prototype.setup = function (after_setup_callback) {
    throw 'Not implemented error'
  };

  MessageAdapter.prototype.send = function (message) {
    throw 'Not implemented error'
  };

  // hammer singleton

  var hammer = {
    contextId: null,
    hashChangedActive: true,
    websocketUrl: null,
    messageAdapter: null,
    messageAdapterConstructor: MessageAdapter,

    run: function () {
      if (this.messageAdapter == null) {
        throw 'no hammer adapter set';
      } else {
        this.messageAdapter.setup(function () {
          this.initContext();
          this.url.enable();
        }.bind(this));
      }
    },

    send: function (message) {
      console.log(['<<', message]);
      this.messageAdapter.send(message);
    },

    receive: function (message) {
      console.log(['>>', message]);

      if (message.url) {
        this.url.set(message.url);
      }

      if (message.type === 'initContext') {
        this.contextId = message.contextId;
        this.initContent();
      } else if (message.type === 'update') {
        this.update(message.updates);
      } else {
        console.warn(["wrong message", message]);
      }
    },

    initContext: function () {
      this.send({type: 'initContext', url: location.hash});
    },

    initContent: function () {
      var that = this;
      $$('.app').each(function (app) {
        var appId = app.get('id');
        that.send({type: 'initContent', contextId: that.contextId, appId: appId});
      });
    },

    url: {
      last: null,
      onChange: function () {
//        console.log([this.last, this.current()]);
        if (this.last !== this.current() || this.last === null) {
          console.log('url changed');
          hammer.send({type: 'initContext', url: location.hash});
        }
      },

      enable: function () {
//        jQuery(window).bind('hashchange', this.onChange.bind(this));
        window.onhashchange = this.onChange.bind(this);
      },
//      disable: function () {
//        jQuery(window).unbind('hashchange', this.onChange.bind(this)); // TODO probably this is not working
//      },

      set: function (url) {
        location.hash = url;
        hammer.url.last = url;
      },

      current: function () {
        var url = location.hash;
        if (url.startsWith('#')) {
          return url.slice(1);
        } else {
          return url;
        }
      }
    },

    onUpdate: null,

    update: function (updates) {
//      console.log("updating");
      var componentsArray = $$('.component');
      var components = {};
      componentsArray.each(function (component) {
        components[component.get('id')] = component;
      });

//      console.log(components);
      updates.each(function (update) {
        var key = update[0];
        var value = update[1];
//        console.log("updating: " + key);

        var updateHolder = $E('div', {html: value});
        var childComponents = updateHolder.children().first().find('.component');
//        console.log(child_components.map(function (e) {
//          return e._;
//        }));
        childComponents.each(function (component) {
          var replacement = components[component.get('id')];
          if (replacement != null) {
            component.replace(components[component.get('id')]);
          }
        });

//        console.log(['updated result', update_holder.html()]);
        $(key).replace(updateHolder.children().first());
      });

      if (this.onUpdate) {
        this.onUpdate();
      }
    },

    sendAction: function (id, appId, args) {
      this.send({type: 'action', contextId: this.contextId, actionId: id, appId: appId, args: args});
    },

    getAppId: function (element) {
      return element.parents(".app").first().get('id');
    },

    defCallback: function (element, key, eventName, callback) {
      var that = this;
      var dataAttr = "data-" + key;
      var rule = element + "[" + dataAttr + "]";

      rule.on(eventName, function (event) {
        var element = event.target;
        var appId = that.getAppId(element);
        var actionId = element.get(dataAttr);
        callback(appId, actionId, element);
        event.preventDefault();
      });
    }
  };

  jQuery(document).ready(function () {
    hammer.run();
  });

  return hammer;
}());







