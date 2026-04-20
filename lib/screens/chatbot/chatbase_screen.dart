import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatbaseScreen extends StatefulWidget {
  const ChatbaseScreen({super.key});

  @override
  State<ChatbaseScreen> createState() => _ChatbaseScreenState();
}

class _ChatbaseScreenState extends State<ChatbaseScreen> {
  WebViewController? _controller;
  bool _isLoading = true;

  static const String _chatbotId = 'IAqJ7hQK601e1vrDb9kL5';

  @override
  void initState() {
    super.initState();
    _initChatbot();
  }

  Future<void> _initChatbot() async {
    // Clear cookies + storage so each user gets a fresh, isolated chat session
    await WebViewCookieManager().clearCookies();

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';

    final iframeUrl = Uri.parse(
      'https://www.chatbase.co/chatbot-iframe/$_chatbotId?userId=$userId',
    );

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            // Also wipe localStorage via JS after the page loads
            await _controller?.runJavaScript('localStorage.clear(); sessionStorage.clear();');
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (_) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(iframeUrl);

    if (mounted) {
      setState(() => _controller = controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MindHug Assistant'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SafeArea(
        child: _controller == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  WebViewWidget(controller: _controller!),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
      ),
    );
  }
}
