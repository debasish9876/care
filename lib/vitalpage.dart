import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';



class Vitalpage extends StatelessWidget {


  @override

  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('http://192.168.122.97/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('http://192.168.122.54/'));

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Vital Reports'),backgroundColor: Colors.teal),
      body: WebViewWidget(controller: controller),
    );
  }
}
