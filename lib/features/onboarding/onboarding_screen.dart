import 'package:flutter/material.dart';
import 'package:google_hackathon_app/core/auth_service.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await AuthService().setOnboardingComplete();
    widget.onFinished();
  }

  void _next() {
    if (_page == 1) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int index) => setState(() => _page = index),
                children: const [
                  _OnboardingPage(
                    icon: Icons.water_drop_outlined,
                    title: 'Pakistan needs you prepared',
                    body:
                        'Floods, heatwaves, and earthquakes affect millions across Pakistan every year. '
                        'Stay informed about incidents near you and help your community respond faster.',
                  ),
                  _OnboardingPage(
                    icon: Icons.shield_outlined,
                    title: 'See alerts. Report safely. Track status.',
                    body:
                        '• Browse verified and community-reported incidents\n'
                        '• View hazards on the map around Karachi\n'
                        '• Check nationwide incident trends\n'
                        '• Submit what you see — your report can save lives',
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppDimens.space24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (int i) {
                  return Container(
                    width: AppDimens.space8,
                    height: AppDimens.space8,
                    margin: EdgeInsets.symmetric(horizontal: AppDimens.space4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _page == i
                          ? AppColors.primary
                          : AppColors.mutedForeground.withValues(alpha: 0.4),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.space24,
                0,
                AppDimens.space24,
                AppDimens.space24,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_page == 1 ? 'Get started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.space32,
        vertical: AppDimens.space24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppDimens.iconOnboarding, color: AppColors.mapAccent),
          SizedBox(height: AppDimens.space32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: AppDimens.space16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedForeground,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
