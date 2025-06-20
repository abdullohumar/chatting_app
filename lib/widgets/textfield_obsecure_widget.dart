import 'package:chatting_app/provider/obscure_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextFieldObscure extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;

  const TextFieldObscure({
    super.key,
    required this.controller,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ObscureProvider(),
      child: Consumer<ObscureProvider>(
        builder: (context, value, child) {
          final obscureText = value.obscureText;

          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFF667eea),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText 
                        ? Icons.visibility_outlined 
                        : Icons.visibility_off_outlined,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    value.obscureText = !obscureText;
                  },
                ),
                hintText: hintText ?? 'Password',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}