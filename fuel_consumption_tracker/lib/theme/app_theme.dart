import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // ---- Light ----
  static const Color primaryLight = Color(0xFF0D9488);
  static const Color onPrimaryLight = Colors.white;
  static const Color primaryContainerLight = Color(0xFFCCFBF1);
  static const Color onPrimaryContainerLight = Color(0xFF064E3B);

  static const Color secondaryLight = Color(0xFF475569);
  static const Color onSecondaryLight = Colors.white;
  static const Color secondaryContainerLight = Color(0xFFE2E8F0);
  static const Color onSecondaryContainerLight = Color(0xFF1E293B);

  static const Color tertiaryLight = Color(0xFFD97706);
  static const Color onTertiaryLight = Colors.white;
  static const Color tertiaryContainerLight = Color(0xFFFEF3C7);
  static const Color onTertiaryContainerLight = Color(0xFF78350F);

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariedLight = Color(0xFFF1F5F9);
  static const Color onSurfaceLight = Color(0xFF0F172A);
  static const Color outlineLight = Color(0xFF64748B);
  static const Color outlineVariantLight = Color(0xFFE2E8F0);

  static const Color errorLight = Color(0xFFDC2626);
  static const Color onErrorLight = Colors.white;
  static const Color errorContainerLight = Color(0xFFFEE2E2);
  static const Color onErrorContainerLight = Color(0xFF991B1B);

  static const Color successLight = Color(0xFF059669);
  static const Color warningLight = Color(0xFFD97706);

  // ---- Dark ----
  static const Color primaryDark = Color(0xFF5EEAD4);
  static const Color onPrimaryDark = Color(0xFF064E3B);
  static const Color primaryContainerDark = Color(0xFF134E4A);
  static const Color onPrimaryContainerDark = Color(0xFFCCFBF1);

  static const Color secondaryDark = Color(0xFF94A3B8);
  static const Color onSecondaryDark = Color(0xFF1E293B);
  static const Color secondaryContainerDark = Color(0xFF334155);
  static const Color onSecondaryContainerDark = Color(0xFFE2E8F0);

  static const Color tertiaryDark = Color(0xFFFCD34D);
  static const Color onTertiaryDark = Color(0xFF78350F);
  static const Color tertiaryContainerDark = Color(0xFF78350F);
  static const Color onTertiaryContainerDark = Color(0xFFFEF3C7);

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariedDark = Color(0xFF334155);
  static const Color onSurfaceDark = Color(0xFFF1F5F9);
  static const Color outlineDark = Color(0xFF94A3B8);
  static const Color outlineVariantDark = Color(0xFF334155);

  static const Color errorDark = Color(0xFFFCA5A5);
  static const Color onErrorDark = Color(0xFF991B1B);
  static const Color errorContainerDark = Color(0xFF991B1B);
  static const Color onErrorContainerDark = Color(0xFFFEE2E2);

  static const Color successDark = Color(0xFF6EE7B7);
  static const Color warningDark = Color(0xFFFCD34D);

  static Color semanticPositive(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? successDark : successLight;

  static Color semanticInfo(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? primaryDark : primaryLight;

  static Color semanticWarning(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? warningDark : warningLight;

  static Color semanticTertiary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? tertiaryDark : tertiaryLight;

  static ThemeData get lightTheme {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: onPrimaryLight,
      primaryContainer: primaryContainerLight,
      onPrimaryContainer: onPrimaryContainerLight,
      secondary: secondaryLight,
      onSecondary: onSecondaryLight,
      secondaryContainer: secondaryContainerLight,
      onSecondaryContainer: onSecondaryContainerLight,
      tertiary: tertiaryLight,
      onTertiary: onTertiaryLight,
      tertiaryContainer: tertiaryContainerLight,
      onTertiaryContainer: onTertiaryContainerLight,
      error: errorLight,
      onError: onErrorLight,
      errorContainer: errorContainerLight,
      onErrorContainer: onErrorContainerLight,
      surface: surfaceLight,
      onSurface: onSurfaceLight,
      surfaceContainerHighest: surfaceVariedLight,
      outline: outlineLight,
      outlineVariant: outlineVariantLight,
      shadow: Color(0xFF064E3B),
      scrim: Color(0x660F172A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: surfaceLight,
      cardColor: surfaceLight,
      dividerColor: outlineVariantLight,
      shadowColor: const Color(0x14064E3B),
      fontFamily: 'Inter',
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      textTheme: _textTheme(onSurfaceLight),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: onSurfaceLight,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: onSurfaceLight),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xCCFFFFFF),
        elevation: 0,
        shadowColor: const Color(0x0A064E3B),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: onPrimaryLight,
          elevation: 0,
          shadowColor: primaryLight.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          minimumSize: const Size.fromHeight(52),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return primaryLight.withValues(alpha: 0.14);
            }
            return primaryLight.withValues(alpha: 0.06);
          }),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: onPrimaryLight,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          minimumSize: const Size.fromHeight(48),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return primaryLight.withValues(alpha: 0.14);
            }
            return primaryLight.withValues(alpha: 0.06);
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          side: BorderSide(color: primaryLight, width: 1.25),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x0D000000),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: outlineLight.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: outlineLight.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryLight, width: 1.75),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorLight, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorLight, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: outlineLight,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color: primaryLight,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: outlineLight.withValues(alpha: 0.6),
          fontSize: 15,
        ),
        errorStyle: TextStyle(
          color: errorLight,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: outlineLight.withValues(alpha: 0.8),
        suffixIconColor: outlineLight.withValues(alpha: 0.8),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0x0D000000),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: outlineLight.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: outlineLight.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryLight, width: 1.75),
          ),
        ),
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(surfaceLight),
          elevation: const WidgetStatePropertyAll(6),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: outlineVariantLight, width: 1),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0x0D000000),
        selectedColor: primaryContainerLight,
        labelStyle: TextStyle(
          color: onSurfaceLight,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: TextStyle(
          color: primaryLight,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: outlineVariantLight,
            width: 1,
          ),
        ),
        side: BorderSide(
          color: outlineVariantLight,
          width: 1,
        ),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xF2FFFFFF),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 76,
        indicatorColor: primaryLight.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryLight,
              letterSpacing: 0.1,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: outlineLight,
            letterSpacing: 0.1,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primaryLight, size: 25, weight: 600);
          }
          return IconThemeData(color: outlineLight, size: 23);
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 16,
        modalBackgroundColor: surfaceLight,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        elevation: 20,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurfaceLight,
          letterSpacing: -0.2,
        ),
        contentTextStyle: TextStyle(
          fontSize: 15,
          color: outlineLight,
          height: 1.5,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurfaceLight,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      dividerTheme: DividerThemeData(
        color: outlineVariantLight,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.transparent,
        selectedTileColor: primaryContainerLight.withValues(alpha: 0.5),
        iconColor: outlineLight,
        textColor: onSurfaceLight,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSurfaceLight,
        ),
        subtitleTextStyle: TextStyle(fontSize: 13, color: outlineLight),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: onPrimaryLight,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 16,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryLight,
        linearTrackColor: primaryContainerLight,
        circularTrackColor: primaryContainerLight,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryLight,
        inactiveTrackColor: primaryContainerLight,
        thumbColor: primaryLight,
        overlayColor: primaryLight.withValues(alpha: 0.12),
        valueIndicatorColor: primaryLight,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return onPrimaryLight;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLight;
          }
          return outlineVariantLight;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return outlineVariantLight;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLight;
          }
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(onPrimaryLight),
        side: BorderSide(color: outlineLight, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLight;
          }
          return outlineLight;
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryLight,
        unselectedLabelColor: outlineLight,
        indicatorColor: primaryLight,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: onSurfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceLight,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: outlineVariantLight, width: 1),
        ),
        textStyle: TextStyle(
          fontSize: 14,
          color: onSurfaceLight,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: onPrimaryDark,
      primaryContainer: primaryContainerDark,
      onPrimaryContainer: onPrimaryContainerDark,
      secondary: secondaryDark,
      onSecondary: onSecondaryDark,
      secondaryContainer: secondaryContainerDark,
      onSecondaryContainer: onSecondaryContainerDark,
      tertiary: tertiaryDark,
      onTertiary: onTertiaryDark,
      tertiaryContainer: tertiaryContainerDark,
      onTertiaryContainer: onTertiaryContainerDark,
      error: errorDark,
      onError: onErrorDark,
      errorContainer: errorContainerDark,
      onErrorContainer: onErrorContainerDark,
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      surfaceContainerHighest: surfaceVariedDark,
      outline: outlineDark,
      outlineVariant: outlineVariantDark,
      shadow: Color(0xFF000000),
      scrim: Color(0x660F172A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: surfaceDark,
      cardColor: surfaceDark,
      dividerColor: outlineVariantDark,
      shadowColor: const Color(0x40000000),
      fontFamily: 'Inter',
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      }),
      textTheme: _textTheme(onSurfaceDark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurfaceDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: onSurfaceDark,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: onSurfaceDark),
      ),
      cardTheme: CardThemeData(
        color: const Color(0x1AFFFFFF),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: onPrimaryDark,
          elevation: 0,
          shadowColor: primaryDark.withValues(alpha: 0.25),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          minimumSize: const Size.fromHeight(52),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return primaryDark.withValues(alpha: 0.16);
            }
            return primaryDark.withValues(alpha: 0.07);
          }),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: onPrimaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          minimumSize: const Size.fromHeight(48),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return primaryDark.withValues(alpha: 0.16);
            }
            return primaryDark.withValues(alpha: 0.07);
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          side: BorderSide(color: primaryDark, width: 1.25),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x12FFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryDark, width: 1.75),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorDark, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorDark, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: outlineDark,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color: primaryDark,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: outlineDark.withValues(alpha: 0.55),
          fontSize: 15,
        ),
        errorStyle: TextStyle(
          color: errorDark,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: outlineDark.withValues(alpha: 0.8),
        suffixIconColor: outlineDark.withValues(alpha: 0.8),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0x12FFFFFF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryDark, width: 1.75),
          ),
        ),
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(surfaceDark),
          elevation: const WidgetStatePropertyAll(8),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: outlineVariantDark, width: 1),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0x12FFFFFF),
        selectedColor: primaryContainerDark,
        labelStyle: TextStyle(
          color: onSurfaceDark,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: TextStyle(
          color: primaryDark,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xE61E293B),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 76,
        indicatorColor: primaryDark.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryDark,
              letterSpacing: 0.1,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: outlineDark,
            letterSpacing: 0.1,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primaryDark, size: 25, weight: 600);
          }
          return IconThemeData(color: outlineDark, size: 23);
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 16,
        modalBackgroundColor: surfaceDark,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        elevation: 20,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurfaceDark,
          letterSpacing: -0.2,
        ),
        contentTextStyle: TextStyle(
          fontSize: 15,
          color: outlineDark,
          height: 1.5,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurfaceDark,
        contentTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      dividerTheme: DividerThemeData(
        color: outlineVariantDark,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.transparent,
        selectedTileColor: primaryContainerDark.withValues(alpha: 0.4),
        iconColor: outlineDark,
        textColor: onSurfaceDark,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSurfaceDark,
        ),
        subtitleTextStyle: TextStyle(fontSize: 13, color: outlineDark),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryDark,
        foregroundColor: onPrimaryDark,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 16,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryDark,
        linearTrackColor: primaryContainerDark,
        circularTrackColor: primaryContainerDark,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryDark,
        inactiveTrackColor: primaryContainerDark,
        thumbColor: primaryDark,
        overlayColor: primaryDark.withValues(alpha: 0.15),
        valueIndicatorColor: primaryDark,
        valueIndicatorTextStyle: const TextStyle(
          color: onPrimaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return onPrimaryDark;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryDark;
          }
          return outlineVariantDark;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return outlineVariantDark;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryDark;
          }
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(onPrimaryDark),
        side: BorderSide(color: outlineDark, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryDark;
          }
          return outlineDark;
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryDark,
        unselectedLabelColor: outlineDark,
        indicatorColor: primaryDark,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: onSurfaceDark,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: outlineVariantDark, width: 1),
        ),
        textStyle: TextStyle(
          fontSize: 14,
          color: onSurfaceDark,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color onSurface) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w300,
        color: onSurface,
        letterSpacing: -0.5,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w300,
        color: onSurface,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: onSurface,
        letterSpacing: 0,
        height: 1.22,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -0.5,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -0.4,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -0.2,
        height: 1.33,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -0.2,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: onSurface,
        letterSpacing: 0,
        height: 1.33,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurface,
        letterSpacing: 0,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurface.withValues(alpha: 0.8),
        letterSpacing: 0,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: onSurface.withValues(alpha: 0.65),
        letterSpacing: 0,
        height: 1.33,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
        letterSpacing: 0,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: onSurface.withValues(alpha: 0.8),
        letterSpacing: 0.1,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: onSurface.withValues(alpha: 0.7),
        letterSpacing: 0.2,
        height: 1.45,
      ),
    );
  }
}
