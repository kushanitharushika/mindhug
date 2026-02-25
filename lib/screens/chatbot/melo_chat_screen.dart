import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../services/chatbot_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/melo_logo.dart';

class MindHugChatbot extends StatefulWidget {
  const MindHugChatbot({super.key});

  @override
  State<MindHugChatbot> createState() => _MindHugChatbotState();
}

class _MindHugChatbotState extends State<MindHugChatbot> {
  final List<ChatMessage> messages = List.from([
    ChatMessage(
      text: "Hi 🌸 I’m Melo. I’m here to listen. How are you feeling today?",
      isUser: false,
    ),
  ]);

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  Future<void> _scrollToBottom() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  final ChatbotService _chatbotService = ChatbotService();

  Future<void> _sendBotResponse(String userText) async {
    setState(() => _isTyping = true);
    
    // Simulate thinking delay
    final delay = Random().nextInt(1000) + 500;
    await Future.delayed(Duration(milliseconds: delay));
    
    final response = await _chatbotService.getResponse(userText);

    if (mounted) {
      setState(() {
        messages.add(
          ChatMessage(
            text: response,
            isUser: false,
          ),
        );
        _isTyping = false;
      });
      await _scrollToBottom();
    }
  }

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
    });
    _controller.clear();
    _scrollToBottom();
    _sendBotResponse(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final botMsgColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black45;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MeloLogo(size: 32),
            SizedBox(width: 10),
            Text(
              "Melo",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade300, Colors.purple.shade600],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Chat area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && _isTyping) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: const BoxConstraints(maxWidth: 160),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2C) : Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _TypingDot(),
                          SizedBox(width: 6),
                          _TypingDot(delay: 120),
                          SizedBox(width: 6),
                          _TypingDot(delay: 240),
                        ],
                      ),
                    ),
                  );
                }

                final msg = messages[index];
                return Align(
                  alignment: msg.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      gradient: msg.isUser
                          ? LinearGradient(
                              colors: [
                                Colors.purple.shade400,
                                Colors.pink.shade300,
                              ],
                            )
                          : null,
                      color: msg.isUser ? null : botMsgColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(msg.isUser ? 16 : 4),
                        topRight: Radius.circular(msg.isUser ? 4 : 16),
                        bottomLeft: const Radius.circular(16),
                        bottomRight: const Radius.circular(16),
                      ),
                      boxShadow: [
                        if (!msg.isUser)
                          const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            if (!msg.isUser) const MeloLogo(size: 20),
                            if (!msg.isUser) const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                msg.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: msg.isUser
                                      ? Colors.white
                                      : textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            msg.formattedTime(),
                            style: TextStyle(
                              fontSize: 10,
                              color: msg.isUser ? Colors.white70 : subTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Type how you feel...",
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      hintStyle: TextStyle(color: subTextColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.purple.shade400,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  // ignore: use_super_parameters
  const _TypingDot({Key? key, this.delay = 0}) : super(key: key);

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_ctrl),
      child: SizedBox(
        width: 8,
        height: 8,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.purple.shade400,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
