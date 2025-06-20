import 'package:chatting_app/model/chat.dart';
import 'package:chatting_app/model/profile.dart';
import 'package:chatting_app/provider/firebase_auth_provider.dart';
import 'package:chatting_app/provider/shared_preference_provider.dart';
import 'package:chatting_app/services/firebase_firestore_service.dart';
import 'package:chatting_app/static/firebase_auth_status.dart';
import 'package:chatting_app/static/screen_route.dart';
import 'package:chatting_app/widgets/message_bubble_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _contentController = TextEditingController();
  final _padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 16);
  late final Profile? profile;
  late AnimationController _sendButtonController;

  @override
  void initState() {
    super.initState();
    profile = context.read<FirebaseAuthProvider>().profile;
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chat Room',
                  style: TextStyle(
                    color: Color(0xFF2D3748),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online now',
                  style: TextStyle(
                    color: Colors.green.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Consumer<FirebaseAuthProvider>(
            builder: (context, value, child) {
              return switch (value.authStatus) {
                FirebaseAuthStatus.signingOut => Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 24,
                  height: 24,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF667eea),
                  ),
                ),
                _ => Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.logout_rounded, color: Colors.red.shade400),
                    tooltip: 'Logout',
                    onPressed: () => _tapToSignOut(),
                  ),
                ),
              };
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: StreamProvider<List<Chat>>(
                create: (context) =>
                    context.read<FirebaseFirestoreService>().getMessages(),
                initialData: const <Chat>[],
                catchError: (context, error) {
                  debugPrint("error: $error");
                  return [];
                },
                builder: (context, child) {
                  final chats = Provider.of<List<Chat>>(context);
                  return chats.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No messages yet",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Start a conversation!",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final chat = chats[index];
                            return MessageBubble(
                              content: chat.text,
                              sender: chat.emailSender,
                              isMyChat: chat.emailSender == profile?.email,
                            );
                          },
                        );
                },
              ),
            ),
          ),
          Container(
            padding: _padding,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _contentController,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (text) {
                          if (text.isNotEmpty) {
                            _sendButtonController.forward();
                          } else {
                            _sendButtonController.reverse();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _sendButtonController,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _sendMessage(),
                          borderRadius: BorderRadius.circular(24),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _tapToSignOut() async {
    final sharedPreferenceProvider = context.read<SharedPreferenceProvider>();
    final firebaseAuthProvider = context.read<FirebaseAuthProvider>();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    await firebaseAuthProvider
        .signOutUser()
        .then((value) async {
          await sharedPreferenceProvider.logout();
          navigator.pushReplacementNamed(ScreenRoute.login.name);
        })
        .whenComplete(() {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(firebaseAuthProvider.message ?? ''),
              backgroundColor: Colors.green.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        });
  }

  void _sendMessage() async {
    final service = context.read<FirebaseFirestoreService>();
    final email = profile!.email!;
    final content = _contentController.text;

    if (content.isNotEmpty) {
      await service.sendMessage(text: content, emailSender: email);
      _contentController.clear();
      _sendButtonController.reverse();
    }
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    super.dispose();
  }
}