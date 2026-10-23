import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Palette.purple,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 42, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight - 66),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Start your\ncareer\nhere and\nbecome a\nsuccess\ngamer.',
                  style: TextStyle(
                    fontSize: 58,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -2,
                    color: Colors.white,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    'Play what you love. Find your people.\nYour next great stream starts here.',
                    style: TextStyle(color: Color(0xFFC9C0FF), height: 1.7),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        onPressed: () => open(context, '/login'),
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Palette.purple,
                        ),
                        onPressed: () => open(context, '/register'),
                        child: const Text('Register'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.register = false});
  final bool register;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final form = GlobalKey<FormState>();
  final username = TextEditingController(),
      password = TextEditingController(),
      email = TextEditingController();
  bool hidden = true, remember = true, terms = false;
  @override
  void dispose() {
    username.dispose();
    password.dispose();
    email.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) {
      return;
    }
    if (widget.register && !terms) {
      toast(context, 'Please accept the terms to continue.');
      return;
    }
    await AppScope.of(context).login(remember: widget.register || remember);
    if (!mounted) {
      return;
    }
    if (widget.register) {
      Navigator.pushReplacementNamed(context, '/success');
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    }
  }

  Widget field(
    String label,
    TextEditingController controller,
    String hint, {
    bool secret = false,
    bool isEmail = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        TextFormField(
          key: ValueKey(label),
          controller: controller,
          obscureText: secret && hidden,
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
          autocorrect: !secret,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: secret
                ? IconButton(
                    tooltip: 'Show password',
                    onPressed: () => setState(() => hidden = !hidden),
                    icon: Icon(
                      hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Palette.muted,
                    ),
                  )
                : null,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Please enter your ${label.toLowerCase()}';
            }
            if (secret && v.length < 6) {
              return 'Use at least 6 characters';
            }
            if (isEmail && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.register ? 'Register' : 'Log In')),
    body: SafeArea(
      child: Form(
        key: form,
        child: PageBody(
          children: [
            field('Username', username, 'Enter your username'),
            if (widget.register)
              field('Email', email, 'Enter your email', isEmail: true),
            field('Password', password, 'Enter your password', secret: true),
            if (widget.register)
              Row(
                children: [
                  Checkbox(
                    value: terms,
                    onChanged: (v) => setState(() => terms = v!),
                  ),
                  const Expanded(
                    child: Text(
                      'I agree to the Terms of Service and Privacy Policy',
                      style: TextStyle(color: Palette.muted, fontSize: 12),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Checkbox(
                    value: remember,
                    onChanged: (v) => setState(() => remember = v!),
                  ),
                  const Text(
                    'Remember me',
                    style: TextStyle(color: Palette.muted),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => open(context, '/help'),
                    child: const Text(
                      'Trouble logging in?',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            FilledButton(
              key: const ValueKey('auth-submit'),
              onPressed: submit,
              child: Text(widget.register ? 'Create Account' : 'Login'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Local demo · any username and 6+ character password',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Palette.muted),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Or Login With',
                style: TextStyle(color: Palette.muted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            for (final provider in ['Google', 'Discord'])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton.icon(
                  onPressed: () => toast(
                    context,
                    '$provider sign-in requires an authentication service. Use the demo login above.',
                  ),
                  icon: Icon(
                    provider == 'Google' ? Icons.g_mobiledata : Icons.discord,
                    color: Palette.purple,
                    size: 28,
                  ),
                  label: Text('Sign in with $provider'),
                ),
              ),
            const SizedBox(height: 38),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.register
                      ? 'Already have an account?'
                      : 'Don’t have an account?',
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    widget.register ? '/login' : '/register',
                  ),
                  child: Text(widget.register ? 'Login' : 'Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Palette.purple.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Palette.purple,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'You’re all set!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Beatrix. Discover your next\nfavourite creator and join the conversation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Palette.muted),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (_) => false,
                ),
                child: const Text('Let’s Explore'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
