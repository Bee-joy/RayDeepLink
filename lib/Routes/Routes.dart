import 'package:flutter/material.dart';
import 'package:webview/WebView/Test.dart';

class Routes {
  static Map<String, WidgetBuilder> all = <String, WidgetBuilder>{
    '/test': (BuildContext context) => const Test(),
  };
}
