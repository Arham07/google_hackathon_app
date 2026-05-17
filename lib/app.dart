import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_hackathon_app/core/auth_service.dart';
import 'package:google_hackathon_app/features/auth/login_screen.dart';
import 'package:google_hackathon_app/features/home/main_shell.dart';
import 'package:google_hackathon_app/features/onboarding/onboarding_screen.dart';
import 'package:google_hackathon_app/theme/app_theme.dart';

enum _AppGate { loading, onboarding, login, home }

class CiroApp extends StatefulWidget {
  const CiroApp({super.key});

  @override
  State<CiroApp> createState() => _CiroAppState();
}

class _CiroAppState extends State<CiroApp> {
  final AuthService _auth = AuthService();
  _AppGate _gate = _AppGate.loading;

  @override
  void initState() {
    super.initState();
    _resolveGate();
  }

  Future<void> _resolveGate() async {
    final bool onboardingDone = await _auth.isOnboardingComplete();
    final bool loggedIn = await _auth.isLoggedIn();
    setState(() {
      if (!onboardingDone) {
        _gate = _AppGate.onboarding;
      } else if (!loggedIn) {
        _gate = _AppGate.login;
      } else {
        _gate = _AppGate.home;
      }
    });
  }

  void _goLogin() => setState(() => _gate = _AppGate.login);

  void _goHome() => setState(() => _gate = _AppGate.home);

  void _goLoginFromHome() => setState(() => _gate = _AppGate.login);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'CIRO Alerts',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme(),
          home: switch (_gate) {
            _AppGate.loading => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            _AppGate.onboarding => OnboardingScreen(onFinished: _goLogin),
            _AppGate.login => LoginScreen(onLoggedIn: _goHome),
            _AppGate.home => MainShell(onLogout: _goLoginFromHome),
          },
        );
      },
    );
  }
}
