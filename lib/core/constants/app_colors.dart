import 'package:flutter/material.dart';

/// CoachBoard — charcoal gym floor, neon lime.
class AppColors {
  static const Color primary = Color(0xFFB8F53A);
  static const Color primaryLight = Color(0xFFD4FF7A);
  static const Color primarySoft = Color(0xFF1C2A10);
  static const Color primaryMuted = Color(0xFF6B8F22);

  static const Color accent = Color(0xFFB8F53A);
  static const Color accentLight = Color(0xFFD4FF7A);
  static const Color accentDeep = Color(0xFF7CFF6B);
  static const Color success = Color(0xFFB8F53A);
  static const Color successDeep = Color(0xFF6B8F22);
  static const Color warning = Color(0xFFE8B84A);
  static const Color error = Color(0xFFFF6B6B);
  static const Color coin = Color(0xFFE8C56A);
  static const Color onGold = Color(0xFF1A1C12);

  static const Color paint = Color(0xFFB8F53A);
  static const Color tiles = Color(0xFF7CFF6B);
  static const Color concrete = Color(0xFF3D8B66);
  static const Color flooring = Color(0xFFE8B84A);
  static const Color wallpaper = Color(0xFF7B6CF6);

  static const List<Color> subjects = [
    Color(0xFFB8F53A),
    Color(0xFF7CFF6B),
    Color(0xFF4ECDC4),
    Color(0xFFE8B84A),
    Color(0xFF7B6CF6),
    Color(0xFFFF6B6B),
  ];

  static const Color background = Color(0xFF0A0E0C);
  static const Color surface = Color(0xFF141A16);
  static const Color surfaceElevated = Color(0xFF1B231D);
  static const Color surfaceVariant = Color(0xFF222B24);
  static const Color border = Color(0xFF2A352C);
  static const Color borderBright = Color(0xFFB8F53A);

  static const Color textPrimary = Color(0xFFF4F7F1);
  static const Color textSecondary = Color(0xFF9AA89A);
  static const Color textMuted = Color(0xFF6B756C);
  static const Color onPrimary = Color(0xFF10180C);
  static const Color onSurface = textPrimary;
  static const Color onSurfaceVariant = textSecondary;

  static const Color navBar = Color(0xFF0D1210);
  static const Color navActive = primary;
  static const Color navInactive = Color(0xFF6B756C);

  static const Color darkBackground = background;
  static const Color darkSurface = surface;
  static const Color darkCard = surfaceElevated;
  static const Color trueBlack = Color(0xFF070A08);
  static const Color darkInk = textPrimary;

  static const Color lightBackground = background;
  static const Color lightSurface = surface;
  static const Color lightPrimaryTint = Color(0xFF1C2A10);
  static const Color lightWarmTint = Color(0xFF1B231D);
  static const Color lightTextPrimary = textPrimary;

  static const Color salon = background;
  static const Color salonCard = surface;
  static const Color salonLine = border;

  static const List<Color> papers = [
    Color(0xFF141A16),
    Color(0xFF1B231D),
    Color(0xFF1C2A10),
    Color(0xFF222B24),
  ];

  static const List<Color> extraPapers = [
    Color(0xFF1B231D),
    Color(0xFF141A16),
  ];

  static Color paperAt(int index, {bool extras = false}) {
    final all = extras ? [...papers, ...extraPapers] : papers;
    if (all.isEmpty) return surface;
    return all[index % all.length];
  }

  static Color brand(BuildContext context) => Theme.of(context).colorScheme.primary;
  static Color onBrand(BuildContext context) => Theme.of(context).colorScheme.onPrimary;
  static Color page(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
  static Color brandSoft(BuildContext context) =>
      Color.lerp(page(context), brand(context), 0.14) ?? primarySoft;
  static Color sheet(BuildContext context) => Theme.of(context).colorScheme.surface;
  static Color ink(BuildContext context) => Theme.of(context).colorScheme.onSurface;
  static Color muted(BuildContext context) => Theme.of(context).colorScheme.onSurfaceVariant;
  static Color card(BuildContext context) => Theme.of(context).colorScheme.surface;
  static Color elevated(BuildContext context) =>
      Color.lerp(card(context), Colors.white, Theme.of(context).brightness == Brightness.dark ? 0.08 : 0.12) ??
      card(context);
  static Color line(BuildContext context) => Theme.of(context).colorScheme.outline;
  static Color navBarColor(BuildContext context) =>
      Color.lerp(page(context), card(context), 0.7) ?? navBar;
  static Color paper(BuildContext context, int index) {
    final t = 0.05 + (index.abs() % 4) * 0.06;
    return Color.lerp(card(context), brand(context), t) ?? card(context);
  }

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF10150F), Color(0xFF0A0E0C)],
  );

  static const LinearGradient gameGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF141A16), Color(0xFF0A0E0C)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4FF7A), Color(0xFFB8F53A)],
  );

  static const LinearGradient accentGradient = primaryGradient;
  static const LinearGradient goldShimmer = LinearGradient(
    colors: [Color(0xFFE8C56A), Color(0xFFC49A3C)],
  );
  static const LinearGradient shopPromoGradient = LinearGradient(
    colors: [Color(0xFF1C2A10), Color(0xFF141A16)],
  );
  static const LinearGradient vipGoldGradient = goldShimmer;
  static const LinearGradient shopVipHeroGradient = shopPromoGradient;
  static const LinearGradient successGradient = primaryGradient;
  static const LinearGradient cardGlow = LinearGradient(
    colors: [Color(0xFF1B231D), Color(0xFF141A16)],
  );

  static List<BoxShadow> softShadow({double opacity = 0.10}) => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: opacity),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
