import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebViewScreen extends StatefulWidget {
  static const routeName = '/webview';
  final url;

  WebViewScreen([this.url]);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      scrollBar: true,
      url: widget.url,
      appBar: AppBar(title: Text('Webview'),),
      withZoom: true,
      hidden: true,
    );
  }
}