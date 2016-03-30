var Nested = React.createClass({
  render: function() {
    var level = this.props.level;
    if (level > 1) {
      return React.createElement(Nested, {level: level - 1});
    }

    return React.createElement('div', {});
  }
});

var testTypes = {
  'DEEP': 'DEEP',
  'SHALLOW': 'SHALLOW'
};

var TEST_TYPE;
var LEVELS;
var COUNT;
function runTest() {
  var i, t0, t1;
  var time, message;

  switch (TEST_TYPE) {
    case testTypes.DEEP:
      var mountNode = document.createElement('div');
      React.render(React.createElement(Nested, {level: LEVELS}), mountNode);
      t0 = performance.now();
      for (i=0; i<COUNT; i++) {
        React.render(React.createElement(Nested, {level: LEVELS}), mountNode);
      }
      t1 = performance.now();

      message = ["Rerendering ", LEVELS, " levels of components (sample size = ", COUNT, ") took "];
      break;

    case testTypes.SHALLOW:
      t0 = performance.now();
      for (i=0; i<COUNT; i++) {
        React.render(React.createElement(Nested, {level: LEVELS}), document.createElement('div'));
      }
      t1 = performance.now();

      message = ["Rendering ", LEVELS, " levels of components (sample size = ", COUNT, ") took "];
      break;
  }

  time = (t1 - t0) / COUNT;

  var status = document.createElement('div');
  React.render(React.DOM.div({},
    message,
    React.DOM.input({
      'style': {'fontFamily': 'monospace'},
      'readOnly': true,
      'value': time
    }),
    " milliseconds."
  ), status);
  document.body.appendChild(status);
}


var getQueryString = function ( field, url ) {
    var href = url ? url : window.location.href;
    var reg = new RegExp( '[?&]' + field + '=([^&#]*)', 'i' );
    var string = reg.exec(href);
    return string ? string[1] : null;
};

LEVELS = parseInt(getQueryString('levels'));
COUNT = parseInt(getQueryString('count'));
TEST_TYPE = (getQueryString('test') || '').toUpperCase();

if (isNaN(LEVELS) || isNaN(COUNT) || !(TEST_TYPE in testTypes)) {
  throw 'Invalid query params. Requires `levels`, `count`, and `test`.';
}

runTest();
