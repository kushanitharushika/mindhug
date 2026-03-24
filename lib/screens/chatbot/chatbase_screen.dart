import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatbaseScreen extends StatefulWidget {
  const ChatbaseScreen({super.key});

  @override
  State<ChatbaseScreen> createState() => _ChatbaseScreenState();
}

class _ChatbaseScreenState extends State<ChatbaseScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // The chatbase embed URL based on the user's snippet.
    // The chatbase snippet uses script src="https://www.chatbase.co/embed.min.js" id="IAqJ7hQK601e1vrDb9kL5"
    // The standard chatbase iframe URL is:
    final iframeUrl = Uri.parse('https://www.chatbase.co/chatbot-iframe/IAqJ7hQK601e1vrDb9kL5');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(iframeUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
