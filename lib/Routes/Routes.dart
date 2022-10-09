import 'package:flutter/material.dart';
import 'package:webview/WebView/Login/Register.dart';

class Routes {
  static Map<String, WidgetBuilder> all = <String, WidgetBuilder>{
    '/test': (BuildContext context) => Register(),
  };
}
