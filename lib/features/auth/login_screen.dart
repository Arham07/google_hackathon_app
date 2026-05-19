import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_hackathon_app/core/auth_service.dart';
import 'package:google_hackathon_app/features/auth/signup_screen.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/app_text_styles.dart';
import 'package:google_hackathon_app/utils/pakistan_validators.dart';
import 'package:google_hackathon_app/widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLoggedIn});

  final VoidCallback onLoggedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthService _auth = AuthService();

  bool _otpSent = false;
  bool _loading = false;
  String? _normalizedPhone;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final String? phone = PakistanValidators.normalizePhone(_phoneController.text);
    if (phone == null) return;

    setState(() => _loading = true);
    try {
      await _auth.sendOtp(phone: phone);
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _normalizedPhone = phone;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP sent to ${PakistanValidators.formatPhone(phone)} '
            '(demo: use ${AuthService.demoOtp})',
          ),
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final String otp = _otpController.text.trim();
    if (!_auth.verifyOtp(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit OTP')),
      );
      return;
    }

    final String phone = _normalizedPhone ??
        PakistanValidators.normalizePhone(_phoneController.text)!;

    setState(() => _loading = true);
    await _auth.loginWithPhoneOtp(phone: phone);
    if (!mounted) return;
    setState(() => _loading = false);
    widget.onLoggedIn();
  }

  void _changePhone() {
    setState(() {
      _otpSent = false;
      _normalizedPhone = null;
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimens.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppDimens.space32),
                const Center(child: AppLogo()),
                SizedBox(height: AppDimens.space16),
                const Text(
                  'BaKhabarAlerts',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.screenTitle,
                ),
                SizedBox(height: AppDimens.space8),
                Text(
                  _otpSent
                      ? 'Enter the code sent to your phone'
                      : 'Sign in with your Pakistani mobile number',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.screenSubtitle,
                ),
                SizedBox(height: AppDimens.space40),
                if (!_otpSent) ...[
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    enabled: !_loading,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[\d\s+\-()]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Mobile number',
                      hintText: '03XX XXXXXXX',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: PakistanValidators.validatePhone,
                    onFieldSubmitted: (_) => _sendOtp(),
                  ),
                  SizedBox(height: AppDimens.space32),
                  ElevatedButton(
                    onPressed: _loading ? null : _sendOtp,
                    child: _loading
                        ? SizedBox(
                            height: AppDimens.space20,
                            width: AppDimens.space20,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Get OTP'),
                  ),
                ] else ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.phone_outlined),
                    title: Text(
                      PakistanValidators.formatPhone(_normalizedPhone!),
                      style: AppTextStyles.sectionTitle,
                    ),
                    subtitle: const Text('OTP sent to this number'),
                    trailing: TextButton(
                      onPressed: _loading ? null : _changePhone,
                      child: const Text('Change'),
                    ),
                  ),
                  SizedBox(height: AppDimens.space16),
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    enabled: !_loading,
                    maxLength: 6,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'OTP',
                      hintText: '6-digit code',
                      prefixIcon: Icon(Icons.sms_outlined),
                      counterText: '',
                    ),
                    validator: (String? value) {
                      final String v = value?.trim() ?? '';
                      if (v.isEmpty) return 'Enter the OTP';
                      if (!_auth.verifyOtp(v)) return 'Enter a 6-digit code';
                      return null;
                    },
                    onFieldSubmitted: (_) => _verifyOtp(),
                  ),
                  SizedBox(height: AppDimens.space32),
                  ElevatedButton(
                    onPressed: _loading ? null : _verifyOtp,
                    child: _loading
                        ? SizedBox(
                            height: AppDimens.space20,
                            width: AppDimens.space20,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verify & continue'),
                  ),
                  SizedBox(height: AppDimens.space12),
                  TextButton(
                    onPressed: _loading ? null : _sendOtp,
                    child: const Text('Resend OTP'),
                  ),
                ],
                SizedBox(height: AppDimens.space16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SignupScreen(onSignedUp: widget.onLoggedIn),
                      ),
                    );
                  },
                  child: const Text('Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
