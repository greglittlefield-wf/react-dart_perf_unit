library test_deep_render;

import 'dart:html';
import 'package:react/react.dart' as react;
import 'package:react/react_client.dart';

ReactComponentFactory Nested = react.registerComponent(() => new NestedComponent());
class NestedComponent extends react.Component {
  render() {
    int level = props['level'];
    if (level > 1) {
      return Nested({'level': level - 1});
    }

    return react.div({});
  }
}

enum TestType {
  SHALLOW, DEEP
}

int COUNT;
int LEVELS;
TestType TEST_TYPE;
runTest() {
  double time;
  String message;

  switch(TEST_TYPE) {
    case TestType.SHALLOW:
      double t0 = window.performance.now();
      for (int i=0; i<COUNT; i++) {
        react.render(Nested({'level': LEVELS}), new DivElement());
      }
      double t1 = window.performance.now();

      time = (t1 - t0) / COUNT;
      message = "Initial render of $LEVELS levels of components (sample size = $COUNT) took ";
      break;

    case TestType.DEEP:
      // Initial render
      var div = new DivElement();
      react.render(Nested({'level': LEVELS}), div);

      // Rerender
      double t0 = window.performance.now();
      for (int i=0; i<COUNT; i++) {
        react.render(Nested({'level': LEVELS}), div);
      }
      double t1 = window.performance.now();

      time = (t1 - t0) / COUNT;
      message = "Rerendering $LEVELS levels of components (sample size = $COUNT) took ";
      break;
  }

  var status = document.createElement('div');
  react.render(react.div({},
    message,
    react.input({
      'style': {'fontFamily': 'monospace'},
      'readOnly': true,
      'value': time,
    }),
    " milliseconds."
  ), status);
  document.body.append(status);
}

main() {
  var params = Uri.parse(window.location.toString()).queryParameters;
  try {
    COUNT = int.parse(params['count']);
    LEVELS = int.parse(params['levels']);

    const Map testParamValueToTestType = const {
      'SHALLOW': TestType.SHALLOW,
      'DEEP': TestType.DEEP,
    };
    TEST_TYPE = testParamValueToTestType[params['test'].toUpperCase()];

    if (COUNT.isNaN || LEVELS.isNaN) {
      throw 'Invalid number';
    }
    if (TEST_TYPE == null) {
      throw 'Invalid test type';
    }
  } catch(e) {
    throw 'Invalid query params. Requires `levels`, `count`, and `test`.';
  }

  setClientConfiguration();
  runTest();
}
