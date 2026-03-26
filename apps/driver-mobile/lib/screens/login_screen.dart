import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = '${AppConstants.defaultCountryCode}${_phoneController.text.trim()}';
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.requestOtp(phone);
    if (success && mounted) {
      Navigator.pushNamed(context, '/otp', arguments: phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 1),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: FairGoTheme.darkBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.drive_eta_rounded, size: 40, color: FairGoTheme.primaryCyan),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'FAIRGO DRIVER',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: FairGoTheme.textPrimary, letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text('Sign in with your phone number', style: TextStyle(fontSize: 14, color: FairGoTheme.textSecondary)),
                ),
                const SizedBox(height: 40),
                const Text('Phone Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Row(
                        children: [
                          Text('🇹🇭', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 6),
                          Text('+66', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(hintText: '8X XXX XXXX'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter phone number';
                          if (value.trim().length < 9) return 'Too short';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.error != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(auth.error!, style: const TextStyle(color: FairGoTheme.danger, fontSize: 13)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return ElevatedButton(
                      onPressed: auth.isLoading ? null : _requestOtp,
                      child: auth.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Continue'),
                    );
                  },
                ),
                const Spacer(flex: 2),
                Center(
                  child: Text(
                    'By continuing, you agree to FAIRGO\'s\nDriver Terms and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
