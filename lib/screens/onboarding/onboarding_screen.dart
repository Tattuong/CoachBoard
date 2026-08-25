import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/services/sound_service.dart';
import '../../models/app_theme_preset.dart';
import '../../providers/coach_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../home/main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _pages = [
    ('onboardTitle1', 'onboardDesc1', Icons.calendar_month_outlined),
    ('onboardTitle2', 'onboardDesc2', Icons.timer_outlined),
    ('onboardTitle3', 'onboardDesc3', Icons.picture_as_pdf_outlined),
  ];

  Future<void> _finish() async {
    SoundService.instance.levelComplete();
    await context.read<CoachProvider>().completeOnboarding();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ftr = context.ftrTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ftr.surface,
        body: FtrBackground(
          child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(AppStrings.t(context, 'skipOnboard')),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) {
                    final p = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: ftr.primary.withValues(alpha: 0.5)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Icon(p.$3, size: 36, color: ftr.primary),
                          const SizedBox(height: 28),
                          Text(
                            AppStrings.t(context, p.$1),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.t(context, p.$2),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(fontSize: 16, height: 1.45, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      if (_page < _pages.length - 1) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
                      } else {
                        _finish();
                      }
                    },
                    child: Text(
                      _page < _pages.length - 1 ? AppStrings.t(context, 'next') : AppStrings.t(context, 'getStarted'),
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                    ),
                  ),
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
