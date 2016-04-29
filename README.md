# react-dart_perf_unit

> "Unit"-style performance testing of react-dart component rendering.
>
> Includes tests that compare rendering in react-dart with `dart:js` interop, react-dart with `package:js` interop, and native JS React.

Tested with preliminary performance improvements including new JS interop and lifecycle improvements, based off react-dart 0.8.7:
* Ref: https://github.com/greglittlefield-wf/react-dart/tree/ff42e44ed4080b6bb2c5c2f9b3714f9b77699ebd
* Changes: https://github.com/cleandart/react-dart/compare/e732fac91b469c4c048d68fc89d515a795b3eb2d...greglittlefield-wf:ff42e44ed4080b6bb2c5c2f9b3714f9b77699ebd

### Performance data
Shallow/deep rendering and framerate data are available in the following doc: <https://docs.google.com/spreadsheets/d/1GB8QZZGlgFNw4gx6AuRA242Ardfei0sDAYRcHv_osLU/edit?usp=sharing>

##### Summarized results

react-dart Initial Rendering Time (in terms of pure JS time):
* current: 14.3x
* optimized: 5.7x
* optimized + dart2js tweaks: 3.5x

tl;dr Still not quite as fast as react JS, but much lot faster. Getting really close with the dart2js changes in place.

### Improvement details
To expand on the individual improvements:

##### react-dart:
- Use new/faster package:js JS interop throughout
- Optimize lifecycle methods to eliminate unnecessary Map merging
- Optimize event callback conversion logic (affects non-event-callback props)

##### dart2js:
- Use direct method invocation instead of Function.prototype.apply for Dart functions exposed to the JS
- Optimize the resolution of interceptors for anonymous JS objects
    - Basic explanation: 
    
        Dart code interacts with JS objects by wrapping them in interceptors.
        When Dart code encounters a JS object, it has to get its interceptor.

        For existing objects, Dart checks to see if an interceptor is already associated with that object.
        If one is not found, Dart then has to figure out what kind of interceptor to create. This process has a lot of steps that check for "native" objects (like elements, events, etc), and the last step (basically the final "else" case) resolves to an "UnkownJSInterceptor" if no other one is found.

        By detecting these anonymous JS objects earlier on (by what method is currently unknown), those time-consuming steps can be skipped.
        This gives us a nice performance bump for react-dart due to all of the `props`, `ReactElement`, and `ReactComponent` objects that are used.
