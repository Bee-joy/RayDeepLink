import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViews extends StatefulWidget {
  final String url;
  const WebViews(this.url, {Key? key}) : super(key: key);

  @override
  State<WebViews> createState() => _WebViewsState();
}

class _WebViewsState extends State<WebViews> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(' WebView'),
        ),
        body: WebView(
          initialUrl: widget.url,
        ));
  }
}
