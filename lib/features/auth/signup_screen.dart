import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_hackathon_app/core/auth_service.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/app_text_styles.dart';
import 'package:google_hackathon_app/utils/pakistan_validators.dart';
import 'package:google_hackathon_app/widgets/app_logo.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.onSignedUp});

  final VoidCallback onSignedUp;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final String? phone = PakistanValidators.normalizePhone(_phoneController.text);
    if (phone == null) return;

    setState(() => _loading = true);
    final String cnic = PakistanValidators.formatCnic(_cnicController.text);
    final String? email = _emailController.text.trim().isEmpty
        ? null
        : _emailController.text.trim();

    await AuthService().login(
      name: _nameController.text.trim(),
      phone: phone,
      email: email,
      cnic: cnic,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    widget.onSignedUp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimens.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: AppLogo(height: AppDimens.logoHeightCompact),
                ),
                SizedBox(height: AppDimens.space16),
                const Text(
                  'Join the community alert network',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.screenSubtitle,
                ),
                SizedBox(height: AppDimens.space24),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppDimens.space16),
                TextFormField(
                  controller: _cnicController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'CNIC',
                    hintText: 'XXXXX-XXXXXXX-X',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[\d\-]')),
                    LengthLimitingTextInputFormatter(15),
                  ],
                  validator: PakistanValidators.validateCnic,
                ),
                SizedBox(height: AppDimens.space16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile number',
                    hintText: '03XX XXXXXXX',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[\d\s+\-()]')),
                  ],
                  validator: PakistanValidators.validatePhone,
                ),
                SizedBox(height: AppDimens.space16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: PakistanValidators.validateEmailOptional,
                ),
                SizedBox(height: AppDimens.space16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.length < 6) {
                      return 'At least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppDimens.space16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (String? value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppDimens.space32),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? SizedBox(
                          height: AppDimens.space20,
                          width: AppDimens.space20,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
