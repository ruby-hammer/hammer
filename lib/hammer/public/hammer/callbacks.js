$(document).onReady(function () {
  "use strict";

  hammer.defCallback('a', 'action', 'click', function (appId, actionId, element) {
    hammer.sendAction(actionId, appId);
  });

  hammer.defCallback('a', 'alternative', 'click', function (appId, actionId, element) {
    hammer.sendAction(actionId, appId);
  });

  hammer.defCallback('input', 'value', 'change', function (appId, actionId, element) {
    hammer.sendAction(actionId, appId, element.value());
  });

});

