import 'dart:io';

main(List<String> args) {
  if (args.length != 1) {
    print(
        'Rewrites a transpiled Dart file with dart2js tweaks to improve react-dart interop.\n\n'
        'Step 1: Run `pub build --mode=DEBUG`.\n'
        'Step 2: Run `${Platform.script.toFilePath()} build/web/your_transpiled_dart_file.dart.js`.\n'
        'Step 3: Open your HTML file in build/web/.\n'
    );
    return 0;
  }

  const modifiedMessage = 'MODIFIED with dart2js tweaks';

  const interceptorsPattern = r'lookupAndCacheInterceptor: function(obj) {';
  const convertDartFunctionFastPattern = r'return _call(f, Array.prototype.slice.apply(arguments));';
  const convertDartFunctionFastCaptureThisPattern = r'return _call(f, this, Array.prototype.slice.apply(arguments));';

  var file = new File(args.first);
  var contents = file.readAsStringSync();

  if (contents.contains(modifiedMessage)) {
    print('Contents have already been modified. Rerun `pub build --mode=DEBUG` and run this script again.');
    return 1;
  }

  contents = contents.replaceFirst(interceptorsPattern, interceptorsPattern + r'''
          /// Optimize interceptors for React internals
          if (obj.internal || obj.props) {
            return C.UnknownJavaScriptObject_methods;
          }
  ''').replaceFirst(convertDartFunctionFastPattern,  r'''
          // Optimize convertDartFunctionFast calls
          var t1 = arguments.length;

          if (t1 === 0) {
            if (!!f.call$0)
              return f.call$0();
          } else if (t1 === 1) {
            if (!!f.call$1)
              return f.call$1(arg0);
          } else if (t1 === 2) {
            if (!!f.call$2)
              return f.call$2(arg0, arg1);
          } else if (t1 === 3)  {
            if (!!f.call$3)
              return f.call$3(arg0, arg1, arg2);
          } else if (t1 === 4)  {
            if (!!f.call$4)
              return f.call$4(arg0, arg1, arg2, arg3);
          } else if (t1 === 5)  {
            if (!!f.call$5)
              return f.call$5(arg0, arg1, arg2, arg3, arg4);
          }

    ''' + convertDartFunctionFastPattern
  ).replaceFirst(new RegExp(r'return function\(\) \{\s+// Optimize convertDartFunctionFast calls'),
      r'''return function(arg0, arg1, arg2, arg3, arg4) {
          // Optimize convertDartFunctionFast calls'''
  ).replaceFirst(convertDartFunctionFastCaptureThisPattern,  r'''
          // Optimize convertDartFunctionFastCaptureThis calls
          var t1 = arguments.length;

          if (t1 === 0) {
            if (!!f.call$1)
              return f.call$1(this);
          } else if (t1 === 1) {
            if (!!f.call$2)
              return f.call$2(this, arg0);
          } else if (t1 === 2) {
            if (!!f.call$3)
              return f.call$3(this, arg0, arg1);
          } else if (t1 === 3)  {
            if (!!f.call$4)
              return f.call$4(this, arg0, arg1, arg2);
          } else if (t1 === 4)  {
            if (!!f.call$5)
              return f.call$5(this, arg0, arg1, arg2, arg3);
          }

    ''' + convertDartFunctionFastCaptureThisPattern
  ).replaceFirst(new RegExp(r'return function\(\) \{\s+// Optimize convertDartFunctionFastCaptureThis calls'),
      r'''return function(arg0, arg1, arg2, arg3) {
          // Optimize convertDartFunctionFastCaptureThis calls'''
  );

  contents += '\n/* $modifiedMessage */';

  file.writeAsStringSync(contents);

  print('Changes successfully applied and saved.');
}
