import 'package:chatting_app/provider/firebase_auth_provider.dart';
import 'package:chatting_app/provider/shared_preference_provider.dart';
import 'package:chatting_app/static/firebase_auth_status.dart';
import 'package:chatting_app/static/screen_route.dart';
import 'package:chatting_app/widgets/textfield_obsecure_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();

    final navigator = Navigator.of(context);
    final isLogin = context.read<SharedPreferenceProvider>().isLogin;
    final firebaseAuthProvider = context.read<FirebaseAuthProvider>();

    Future.microtask(() async {
      if (isLogin) {
        await firebaseAuthProvider.updateProfile();
        navigator.pushReplacementNamed(
          ScreenRoute.chat.name,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24.0),
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Hero(
                          tag: 'chatting-app',
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF667eea).withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chatting App',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Welcome back!',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40.0),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Email Address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16.0),
                        TextFieldObscure(
                          controller: _passwordController,
                          hintText: 'Password',
                        ),
                        const SizedBox(height: 32.0),
                        Consumer<FirebaseAuthProvider>(
                          builder: (context, value, child) {
                            return switch (value.authStatus) {
                              FirebaseAuthStatus.authenticating => Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                              _ => _buildGradientButton(
                                onPressed: () => _tapToLogin(),
                                text: 'Sign In',
                                icon: Icons.login_rounded,
                              ),
                            };
                          },
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF718096),
                                ),
                                children: [
                                  const TextSpan(text: 'Don\'t have an account? '),
                                  TextSpan(
                                    text: 'Register here',
                                    style: TextStyle(
                                      color: const Color(0xFF667eea),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () => _goToRegister(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tapToLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if(email.isNotEmpty && password.isNotEmpty) {
      final sharedPreferenceProvider = context.read<SharedPreferenceProvider>();
      final firebaseAuthProvider = context.read<FirebaseAuthProvider>();
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      await firebaseAuthProvider.signInUser(email, password);
      switch (firebaseAuthProvider.authStatus){
        case FirebaseAuthStatus.authenticated:
          await sharedPreferenceProvider.login();
          navigator.pushReplacementNamed(
            ScreenRoute.chat.name
          );
        case _:
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(firebaseAuthProvider.message ?? ""),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
      }
    } else {
      const message = "Fill the email and password correctly";
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text(message),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _goToRegister() async {
    Navigator.pushNamed(
      context,
      ScreenRoute.register.name,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}