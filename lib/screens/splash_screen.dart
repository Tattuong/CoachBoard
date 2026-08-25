import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_strings.dart';
import '../core/services/sound_service.dart';
import '../models/app_theme_preset.dart';
import '../providers/coach_provider.dart';
import '../widgets/circuit_backdrop.dart';
import 'home/main_shell.dart';
import 'onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));
    _enterCtrl.forward();
    _boot();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    try {
      await Future.wait([
        context.read<CoachProvider>().init(),
        Future<void>.delayed(const Duration(milliseconds: 500)),
      ]).timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('Splash boot timeout/error: $e');
    }
    if (!mounted) return;
    SoundService.instance.navigate();
        final onboarded = context.read<CoachProvider>().onboardingComplete;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => onboarded ? const MainShell() : const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preset = context.ftrTheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: preset.surface,
      ),
      child: Scaffold(
        backgroundColor: preset.surface,
        body: CircuitBackdrop(
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Column(
                        children: [
                          Container(
                            width: 168,
                            height: 168,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B1220),
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(color: preset.primary.withValues(alpha: 0.55), width: 1.4),
                              boxShadow: [
                                BoxShadow(color: preset.glowColor.withValues(alpha: 0.28), blurRadius: 28),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            AppStrings.t(context, 'appName'),
                            style: GoogleFonts.nunito(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.t(context, 'appTagline'),
                            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 4),
                  Text(AppStrings.t(context, 'loading'), style: GoogleFonts.nunito(color: Colors.white70, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
