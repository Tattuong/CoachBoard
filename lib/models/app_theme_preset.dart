import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/app_ui.dart';

@immutable
class FtrTheme extends ThemeExtension<FtrTheme> {
  final Color primary;
  final Color primaryLight;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color navBar;
  final Color navActive;
  final Color glowColor;
  final LinearGradient balanceGradient;
  final bool isPremium;

  const FtrTheme({
    required this.primary,
    required this.primaryLight,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.navBar,
    required this.navActive,
    required this.glowColor,
    required this.balanceGradient,
    required this.isPremium,
  });

  factory FtrTheme.fromPreset(AppThemePreset preset, {bool isDark = true}) {
    final surface = isDark ? preset.darkSurface : preset.surface;
    final surfaceElevated = isDark
        ? (Color.lerp(preset.darkSurface, Colors.white, 0.08) ?? preset.darkSurface)
        : (Color.lerp(preset.surface, Colors.white, 0.12) ?? preset.surface);
    final border = Color.lerp(preset.primary, surface, isDark ? 0.55 : 0.72)?.withValues(alpha: isDark ? 0.55 : 0.35) ??
        AppColors.border;
    return FtrTheme(
      primary: preset.primary,
      primaryLight: preset.primaryLight,
      surface: surface,
      surfaceElevated: surfaceElevated,
      border: border,
      navBar: isDark
          ? (Color.lerp(AppColors.navBar, preset.primary, preset.isPremium ? 0.16 : 0) ?? AppColors.navBar)
          : Colors.white,
      navActive: preset.primary,
      glowColor: preset.glowColor,
      balanceGradient: preset.balanceGradient,
      isPremium: preset.isPremium,
    );
  }

  static FtrTheme get fallback => FtrTheme.fromPreset(AppThemePresets.defaultPreset, isDark: true);

  @override
  FtrTheme copyWith({
    Color? primary,
    Color? primaryLight,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? navBar,
    Color? navActive,
    Color? glowColor,
    LinearGradient? balanceGradient,
    bool? isPremium,
  }) {
    return FtrTheme(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      navBar: navBar ?? this.navBar,
      navActive: navActive ?? this.navActive,
      glowColor: glowColor ?? this.glowColor,
      balanceGradient: balanceGradient ?? this.balanceGradient,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  FtrTheme lerp(ThemeExtension<FtrTheme>? other, double t) {
    if (other is! FtrTheme) return this;
    return FtrTheme(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      navBar: Color.lerp(navBar, other.navBar, t)!,
      navActive: Color.lerp(navActive, other.navActive, t)!,
      glowColor: Color.lerp(glowColor, other.glowColor, t)!,
      balanceGradient: LinearGradient.lerp(balanceGradient, other.balanceGradient, t) ?? balanceGradient,
      isPremium: t < 0.5 ? isPremium : other.isPremium,
    );
  }

  BoxDecoration surfaceCard({double radius = 20, bool elevated = true, bool intense = false}) {
    return BoxDecoration(
      color: elevated ? surfaceElevated : surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isPremium ? glowColor.withValues(alpha: intense ? 0.62 : 0.4) : border,
        width: isPremium ? 1.5 : 1,
      ),
      boxShadow: [
        if (isPremium)
          BoxShadow(
            color: glowColor.withValues(alpha: intense ? 0.34 : 0.2),
            blurRadius: intense ? 28 : 18,
            spreadRadius: -2,
            offset: const Offset(0, 6),
          ),
        BoxShadow(color: const Color(0xFF2A241F).withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 8)),
      ],
    );
  }

  BoxDecoration accentButton({double radius = 14}) {
    return BoxDecoration(
      gradient: isPremium ? balanceGradient : null,
      color: isPremium ? null : primary,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: isPremium
          ? [
              BoxShadow(color: glowColor.withValues(alpha: 0.45), blurRadius: 18, offset: const Offset(0, 5)),
              BoxShadow(color: primaryLight.withValues(alpha: 0.22), blurRadius: 8),
            ]
          : null,
    );
  }

  BoxDecoration pillBadge({double radius = 20}) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: isPremium ? glowColor.withValues(alpha: 0.62) : primary, width: isPremium ? 1.5 : 1),
      boxShadow: isPremium ? [BoxShadow(color: glowColor.withValues(alpha: 0.38), blurRadius: 14, spreadRadius: -2)] : null,
    );
  }

  BoxDecoration coinChip({bool header = false}) {
    if (!isPremium) {
      return BoxDecoration(
        color: header ? surfaceElevated : surface,
        borderRadius: BorderRadius.circular(header ? 12 : 20),
        border: Border.all(color: border),
      );
    }
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [surfaceElevated, Color.lerp(surface, glowColor, 0.14)!],
      ),
      borderRadius: BorderRadius.circular(header ? 12 : 20),
      border: Border.all(color: glowColor.withValues(alpha: 0.58), width: 1.5),
      boxShadow: [BoxShadow(color: glowColor.withValues(alpha: 0.32), blurRadius: 14, spreadRadius: -2)],
    );
  }
}

extension FtrThemeContext on BuildContext {
  FtrTheme get ftrTheme => Theme.of(this).extension<FtrTheme>() ?? FtrTheme.fallback;

  Color get lumenAccent => Theme.of(this).colorScheme.primary;
  Color get lumenOnAccent => Theme.of(this).colorScheme.onPrimary;
  Color get lumenAccentSoft =>
      Color.lerp(Theme.of(this).scaffoldBackgroundColor, lumenAccent, 0.2) ?? lumenAccent;
}

class AppThemePreset {
  final String id;
  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color darkBackground;
  final Color darkSurface;
  final Color glowColor;
  final LinearGradient headerGradient;
  final LinearGradient balanceGradient;
  final LinearGradient shopPreviewGradient;

  const AppThemePreset({
    required this.id,
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.darkBackground,
    required this.darkSurface,
    required this.glowColor,
    required this.headerGradient,
    required this.balanceGradient,
    required this.shopPreviewGradient,
  });

  bool get isPremium => id != 'theme_default';

  ThemeData lightTheme() => darkTheme();

  ThemeData darkTheme() => _buildTheme(
        brightness: Brightness.dark,
        scaffold: darkBackground,
        surfaceColor: darkSurface,
        onSurface: AppColors.darkInk,
      );

  ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffold,
    required Color surfaceColor,
    required Color onSurface,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primary,
              onPrimary: primary.computeLuminance() > 0.48 ? const Color(0xFF0A0A0C) : Colors.white,
              secondary: primaryLight,
              tertiary: primaryLight,
              surface: surfaceColor,
              onSurface: onSurface,
              onSurfaceVariant: AppColors.textSecondary,
              outline: Color.lerp(primary, surfaceColor, 0.55)?.withValues(alpha: 0.55),
            )
          : ColorScheme.light(
              primary: primary,
              onPrimary: primary.computeLuminance() > 0.48 ? const Color(0xFF0A0A0C) : Colors.white,
              secondary: primaryLight,
              tertiary: primaryLight,
              surface: surfaceColor,
              onSurface: onSurface,
              onSurfaceVariant: AppColors.textMuted,
              outline: Color.lerp(primary, surfaceColor, 0.55)?.withValues(alpha: 0.35),
            ),
      textTheme: AppTypography.textTheme(brightness, onSurface: onSurface),
      iconTheme: IconThemeData(color: onSurface),
      dialogTheme: DialogThemeData(backgroundColor: surfaceColor, surfaceTintColor: Colors.transparent),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surfaceColor,
      ),
      chipTheme: ChipThemeData(
        selectedColor: Color.lerp(scaffold, primary, 0.22),
        backgroundColor: Color.lerp(scaffold, primary, 0.08),
        labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
        secondaryLabelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
        side: BorderSide.none,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: onSurface,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          color: isDark ? AppColors.textSecondary : AppColors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Color.lerp(primary, surfaceColor, isDark ? 0.55 : 0.72) ?? AppColors.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Color.lerp(primary, surfaceColor, 0.55)?.withValues(alpha: 0.45),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: primary,
        labelColor: primary,
        unselectedLabelColor: AppColors.textMuted,
        dividerColor: Colors.transparent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primary, width: 1.6)),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.45)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? primary : null),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary.withValues(alpha: 0.45) : null,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: primary.computeLuminance() > 0.48 ? const Color(0xFF0A0A0C) : Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primary.computeLuminance() > 0.48 ? const Color(0xFF0A0A0C) : Colors.white,
        ),
      ),
      extensions: [FtrTheme.fromPreset(this, isDark: isDark)],
    );
  }
}

class AppThemePresets {
  AppThemePresets._();

  static const defaultPreset = AppThemePreset(
    id: 'theme_default',
    primary: AppColors.primary,
    primaryLight: AppColors.primaryLight,
    background: AppColors.background,
    surface: AppColors.surface,
    darkBackground: AppColors.darkBackground,
    darkSurface: AppColors.darkSurface,
    glowColor: AppColors.primaryLight,
    headerGradient: AppColors.headerGradient,
    balanceGradient: AppColors.primaryGradient,
    shopPreviewGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1C2A10), Color(0xFF6B8F22), Color(0xFFB8F53A)],
    ),
  );

  static const emerald = AppThemePreset(
    id: 'theme_emerald',
    primary: Color(0xFF2DD4BF),
    primaryLight: Color(0xFF5EEAD4),
    background: Color(0xFF071614),
    surface: Color(0xFF0F2A26),
    darkBackground: Color(0xFF061412),
    darkSurface: Color(0xFF0C2420),
    glowColor: Color(0xFF5EEAD4),
    headerGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF134E4A), Color(0xFF061412)],
    ),
    balanceGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF5EEAD4), Color(0xFF0F766E)],
    ),
    shopPreviewGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF042F2E), Color(0xFF0F766E), Color(0xFF5EEAD4)],
    ),
  );

  static const gold = AppThemePreset(
    id: 'theme_gold',
    primary: Color(0xFFF59E0B),
    primaryLight: Color(0xFFFBBF24),
    background: Color(0xFF140E08),
    surface: Color(0xFF24180E),
    darkBackground: Color(0xFF120E0A),
    darkSurface: Color(0xFF22180F),
    glowColor: Color(0xFFFBBF24),
    headerGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF7C2D12), Color(0xFF120E0A)],
    ),
    balanceGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFBBF24), Color(0xFFEA580C)],
    ),
    shopPreviewGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF431407), Color(0xFFC2410C), Color(0xFFFBBF24)],
    ),
  );

  static const midnight = AppThemePreset(
    id: 'theme_midnight',
    primary: Color(0xFF4338CA),
    primaryLight: Color(0xFFA78BFA),
    background: Color(0xFFE0E7FF),
    surface: Color(0xFFEEF2FF),
    darkBackground: Color(0xFF070B18),
    darkSurface: Color(0xFF12182C),
    glowColor: Color(0xFFC4B5FD),
    headerGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF312E81), Color(0xFF070B18)],
    ),
    balanceGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFC4B5FD), Color(0xFF4F46E5), Color(0xFF1E1B4B)],
    ),
    shopPreviewGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0F172A), Color(0xFF3730A3), Color(0xFFC4B5FD)],
    ),
  );

  static const Map<String, AppThemePreset> byId = {
    'theme_default': defaultPreset,
    'theme_emerald': emerald,
    'theme_gold': gold,
    'theme_midnight': midnight,
  };

  static AppThemePreset get(String? id) => byId[id] ?? defaultPreset;
}

class AppBackground {
  final String id;
  final LinearGradient gradient;

  const AppBackground({required this.id, required this.gradient});

  static const defaultBg = AppBackground(id: 'bg_default', gradient: AppColors.gameGradient);

  static const forest = AppBackground(
    id: 'bg_forest',
    gradient: LinearGradient(
      colors: [Color(0xFF1A3A28), Color(0xFF142018), Color(0xFF1C2E24), Color(0xFF243028)],
      stops: [0.0, 0.38, 0.72, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const aurora = AppBackground(
    id: 'bg_aurora',
    gradient: LinearGradient(
      colors: [Color(0xFF1A2E5A), Color(0xFF141822), Color(0xFF1C2840), Color(0xFF243048)],
      stops: [0.0, 0.35, 0.7, 1.0],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ),
  );

  static const sunset = AppBackground(
    id: 'bg_sunset',
    gradient: LinearGradient(
      colors: [Color(0xFF3A2418), Color(0xFF1C1410), Color(0xFF3A2818), Color(0xFF241C18)],
      stops: [0.0, 0.4, 0.72, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomRight,
    ),
  );

  static const Map<String, AppBackground> byId = {
    'bg_default': defaultBg,
    'bg_forest': forest,
    'bg_aurora': aurora,
    'bg_sunset': sunset,
  };

  static AppBackground get(String? id) => byId[id] ?? defaultBg;
}

class CardStyle {
  final String id;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color accentColor;
  final bool glassEffect;
  final bool neonGlow;

  const CardStyle({
    required this.id,
    this.borderRadius = 18,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.accentColor = AppColors.primaryLight,
    this.glassEffect = false,
    this.neonGlow = false,
  });

  static const defaultStyle = CardStyle(id: 'skin_default');

  static const soft = CardStyle(
    id: 'skin_soft',
    borderRadius: 24,
    glassEffect: true,
  );

  static const neon = CardStyle(
    id: 'skin_neon',
    borderRadius: 16,
    borderWidth: 2,
    borderColor: AppColors.primaryLight,
    accentColor: AppColors.primaryLight,
    neonGlow: true,
  );

  static const Map<String, CardStyle> byId = {
    'skin_default': defaultStyle,
    'skin_soft': soft,
    'skin_neon': neon,
  };

  static CardStyle get(String? id) => byId[id] ?? defaultStyle;

  double paperRadius([double fallback = 22]) => id == 'skin_default' ? fallback : borderRadius;

  BoxDecoration lookDecoration({
    required Color fill,
    required Color accent,
    double? radius,
  }) {
    final r = radius ?? paperRadius();
    if (glassEffect) {
      return BoxDecoration(
        color: fill.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.2),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.22), blurRadius: 28, offset: const Offset(0, 10)),
          BoxShadow(color: Colors.white.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      );
    }
    if (neonGlow) {
      return BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: accent.withValues(alpha: 0.9), width: 1.4),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.55), blurRadius: 22, spreadRadius: -1),
          BoxShadow(color: accent.withValues(alpha: 0.28), blurRadius: 8),
        ],
      );
    }
    return BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(r),
    );
  }

  BoxDecoration gameCardDecoration({
    required Color fill,
    bool highlight = false,
    Color? stateBorder,
    double stateBorderWidth = 1.5,
  }) {
    final hasSkinBorder = borderWidth > 0;
    final defaultBorder = hasSkinBorder ? borderColor : AppColors.border;
    final width = stateBorder != null
        ? stateBorderWidth
        : (hasSkinBorder ? borderWidth : 1.0);
    final border = highlight && stateBorder == null
        ? accentColor.withValues(alpha: 0.85)
        : (stateBorder ?? defaultBorder);

    if (glassEffect) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: fill.withValues(alpha: stateBorder != null ? 0.82 : 0.68),
        border: Border.all(
          color: stateBorder != null ? border : Colors.white.withValues(alpha: 0.16),
          width: width,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: neonGlow ? 0.42 : 0.14),
            blurRadius: neonGlow ? 18 : 22,
            offset: const Offset(0, 8),
          ),
          if (neonGlow)
            BoxShadow(color: accentColor.withValues(alpha: 0.18), blurRadius: 6),
        ],
      );
    }

    return BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: border, width: width),
      boxShadow: neonGlow
          ? [
              BoxShadow(color: accentColor.withValues(alpha: 0.42), blurRadius: 18, spreadRadius: -2),
              BoxShadow(color: accentColor.withValues(alpha: 0.18), blurRadius: 6),
            ]
          : null,
    );
  }
}
