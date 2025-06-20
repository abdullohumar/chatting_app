import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final String sender;
  final bool isMyChat;

  const MessageBubble({
    super.key,
    required this.content,
    required this.sender,
    required this.isMyChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isMyChat ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyChat) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: Text(
                sender.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMyChat ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMyChat)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Text(
                      sender.split('@')[0],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: isMyChat
                        ? const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          )
                        : null,
                    color: isMyChat ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMyChat ? 20 : 4),
                      bottomRight: Radius.circular(isMyChat ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isMyChat
                            ? const Color(0xFF667eea).withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      color: isMyChat ? Colors.white : const Color(0xFF2D3748),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMyChat) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF667eea),
              child: Text(
                sender.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}