$(document).onReady(function () {
  "use strict";

  hammer.onUpdate = function () {
    jQuery("a").each(function (i) {
      this.href = '#' + hammer.url.current();
    });
  };

  hammer.defCallback('a', 'action', 'click', function (appId, actionId, element) {
    hammer.sendAction(actionId, appId);
  });

  hammer.defCallback('span', 'alternative', 'click', function (appId, actionId, element) {
    hammer.sendAction(actionId, appId);
  });

  hammer.defCallback('input', 'value', 'change', function (appId, actionId, element) {
    hammer.sendAction(actionId, appId, element.value());
  });

});

