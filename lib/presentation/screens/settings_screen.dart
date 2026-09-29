import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../state/auth_provider.dart';
import '../state/biometric_provider.dart';
import '../state/currency_provider.dart';
import '../state/expense_provider.dart';
import '../state/language_provider.dart';
import '../state/notification_provider.dart';
import '../state/theme_provider.dart';
import '../widgets/currency_picker_sheet.dart';
import '../widgets/export_report_sheet.dart';
import '../widgets/theme_settings_sheet.dart';
import 'onboarding_screen.dart';
import 'recycle_bin_screen.dart';

/// Full-featured Settings screen offering language translation (English & Sinhala),
/// appearance customization, currency options, data management, and account settings.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final lang = context.read<LanguageProvider>();
    final userEmail = authProvider.user?.email ?? 'your account';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(lang.getText('sign_out')),
        content: Text('${lang.getText('sign_out_confirm')}\n($userEmail)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(lang.getText('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Exit settings
              context.read<ExpenseProvider>().clearData();
              context.read<AuthProvider>().signOut();
            },
            child: Text(lang.getText('sign_out')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final auth = context.watch<AuthProvider>();
    final bio = context.watch<BiometricProvider>();
    final notif = context.watch<NotificationProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final user = auth.user;

    final userName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : (user?.email?.split('@').first ?? 'User');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          lang.getText('settings'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [
          // 1. Language Translation Section (Hero Feature)
          _buildSectionHeader(
            theme: theme,
            title: lang.getText('language'),
            subtitle: lang.getText('language_subtitle'),
            icon: Icons.translate_rounded,
            iconColor: const Color(0xFF6366F1),
          ),
          const SizedBox(height: 12),
          _buildLanguageCards(context, lang, isDark, theme),

          const SizedBox(height: 28),

          // 2. Appearance & Theme Section
          _buildSectionHeader(
            theme: theme,
            title: lang.getText('appearance'),
            subtitle: lang.getText('theme_mode'),
            icon: Icons.palette_rounded,
            iconColor: const Color(0xFFEC4899),
          ),
          const SizedBox(height: 12),
          _buildAppearanceCard(context, themeProvider, lang, isDark, theme),

          const SizedBox(height: 28),

          // 3. Currency Preferences Section (Searchable Dropdown)
          _buildSectionHeader(
            theme: theme,
            title: lang.getText('currency'),
            subtitle: lang.getText('currency_subtitle'),
            icon: Icons.currency_exchange_rounded,
            iconColor: const Color(0xFF0EA5E9),
          ),
          const SizedBox(height: 12),
          _buildCurrencyCard(context, lang, currencyProvider, isDark, theme),

          const SizedBox(height: 28),

          // 4. Security & Biometrics Section
          _buildSectionHeader(
            theme: theme,
            title: lang.getText('security'),
            subtitle: lang.getText('biometric_lock_subtitle'),
            icon: Icons.shield_rounded,
            iconColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _buildSecurityCard(context, lang, bio, isDark, theme),

          const SizedBox(height: 28),

          // 5. Notifications & Alerts Section
          _buildSectionHeader(
            theme: theme,
            title: lang.getText('notifications'),
            subtitle: lang.getText('notifications_subtitle'),
            icon: Icons.notifications_active_rounded,
            iconColor: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(context, lang, notif, isDark, theme),

          const SizedBox(height: 28),

          // 6. Data & Management Section
          _buildSectionHeader(
            theme: theme,
            title: lang.getText('data_management'),
            subtitle: lang.getText('manage_deleted_items'),
            icon: Icons.folder_special_rounded,
            iconColor: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 12),
          _buildDataCard(context, lang, expenseProvider, isDark, theme),

          const SizedBox(height: 28),

          // 4. Account Section
          _buildSectionHeader(
            theme: theme,
            title: lang.getText('account'),
            subtitle: '${lang.getText('logged_in_as')} ${user?.email ?? ""}',
            icon: Icons.person_rounded,
            iconColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _buildAccountCard(context, userName, user?.email ?? '', lang, isDark, theme),

          const SizedBox(height: 28),

          // 5. App Info & Version
          _buildAboutCard(lang, isDark, theme),
        ],
      ),
    );
  }

  /// Section Header with Colored Badge Icon
  Widget _buildSectionHeader({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Interactive Language Selection Cards (English vs Sinhala)
  Widget _buildLanguageCards(
    BuildContext context,
    LanguageProvider lang,
    bool isDark,
    ThemeData theme,
  ) {
    return Column(
      children: [
        // English Option Card
        _buildLanguageTile(
          context: context,
          title: 'English',
          nativeSubtitle: 'Default Language',
          flagEmoji: '🇬🇧',
          isSelected: lang.isEnglish,
          isDark: isDark,
          theme: theme,
          onTap: () {
            lang.setLanguage('en');
            _showLanguageToast(context, 'Language set to English');
          },
        ),
        const SizedBox(height: 10),
        // Sinhala Option Card
        _buildLanguageTile(
          context: context,
          title: 'සිංහල',
          nativeSubtitle: 'Sinhala Language',
          flagEmoji: '🇱🇰',
          isSelected: lang.isSinhala,
          isDark: isDark,
          theme: theme,
          onTap: () {
            lang.setLanguage('si');
            _showLanguageToast(context, 'භාෂාව සිංහලට මාරු කරන ලදී');
          },
        ),
      ],
    );
  }

  /// Single Language Card
  Widget _buildLanguageTile({
    required BuildContext context,
    required String title,
    required String nativeSubtitle,
    required String flagEmoji,
    required bool isSelected,
    required bool isDark,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Flag / Emblem Circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : (isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.grey.shade100),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      flagEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Language Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? (isDark ? Colors.white : theme.colorScheme.primary)
                              : (isDark ? Colors.white : AppColors.textPrimaryLight),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        nativeSubtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Selected Radio Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark ? Colors.white30 : Colors.grey.shade400),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(Icons.check_rounded, size: 16, color: Colors.white),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  /// Appearance Card: Theme Mode pills and Accent Palette
  Widget _buildAppearanceCard(
    BuildContext context,
    ThemeProvider themeProvider,
    LanguageProvider lang,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme Mode Selector
          Text(
            lang.getText('theme_mode'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildThemeSegment(
                title: lang.getText('light_theme'),
                icon: Icons.light_mode_rounded,
                isSelected: themeProvider.themeMode == ThemeMode.light,
                theme: theme,
                isDark: isDark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.light),
              ),
              const SizedBox(width: 8),
              _buildThemeSegment(
                title: lang.getText('dark_theme'),
                icon: Icons.dark_mode_rounded,
                isSelected: themeProvider.themeMode == ThemeMode.dark,
                theme: theme,
                isDark: isDark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
              ),
              const SizedBox(width: 8),
              _buildThemeSegment(
                title: lang.getText('system_theme'),
                icon: Icons.brightness_auto_rounded,
                isSelected: themeProvider.themeMode == ThemeMode.system,
                theme: theme,
                isDark: isDark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.system),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),

          // Accent Color Picker Shortcut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.getText('accent_color'),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Customize highlight shades',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              InkWell(
                onTap: () => ThemeSettingsSheet.show(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Change',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Currency Preferences Card with dropdown arrow to open searchable sheet
  Widget _buildCurrencyCard(
    BuildContext context,
    LanguageProvider lang,
    CurrencyProvider currencyProvider,
    bool isDark,
    ThemeData theme,
  ) {
    final currency = currencyProvider.currentCurrency;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => CurrencyPickerSheet.show(context),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                // Flag / Emblem in circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      currency.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Currency Code & Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            currency.code,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 16.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Symbol Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              currency.symbol,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        currency.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dropdown Button Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Change',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSegment({
    required String title,
    required IconData icon,
    required bool isSelected,
    required ThemeData theme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white : const Color(0xFF18181B))
                : (isDark ? Colors.white10 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? Colors.black : Colors.white)
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Data Management Card: Export, Recycle Bin, Onboarding
  Widget _buildDataCard(
    BuildContext context,
    LanguageProvider lang,
    ExpenseProvider provider,
    bool isDark,
    ThemeData theme,
  ) {
    final count = provider.recycledCount;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Export Report Tile
          ListTile(
            onTap: () {
              ExportReportSheet.show(
                context,
                expenses: provider.filteredExpenses,
                periodTitle: 'Expenses Report',
                totalAmount: provider.selectedMonthTotal,
              );
            },
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.file_download_outlined, color: AppColors.primary, size: 20),
            ),
            title: Text(
              lang.getText('export_report'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
            ),
            subtitle: Text(
              lang.getText('download_expense_records'),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ),
          const Divider(height: 1, indent: 64),

          // Recycle Bin Tile
          ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RecycleBinScreen()),
              );
            },
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.warning, size: 20),
            ),
            title: Text(
              lang.getText('recycle_bin'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
            ),
            subtitle: Text(
              lang.getText('manage_deleted_items'),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (count > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
          ),
          const Divider(height: 1, indent: 64),

          // Onboarding Story Tile
          ListTile(
            onTap: () => OnboardingScreen.show(context),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFC084FC).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFA855F7), size: 20),
            ),
            title: Text(
              lang.getText('onboarding_story'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
            ),
            subtitle: const Text(
              'Replay the introduction walk-through',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Account Details Card
  Widget _buildAccountCard(
    BuildContext context,
    String userName,
    String email,
    LanguageProvider lang,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text(
                lang.getText('sign_out'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: () => _confirmSignOut(context),
            ),
          ),
        ],
      ),
    );
  }

  /// App About Card
  Widget _buildAboutCard(LanguageProvider lang, bool isDark, ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFF18181B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lang.getText('app_name'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            lang.getText('app_version'),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 2),
          Text(
            lang.getText('developed_with_love'),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  /// Security Card with Biometric Lock toggle
  Widget _buildSecurityCard(
    BuildContext context,
    LanguageProvider lang,
    BiometricProvider bio,
    bool isDark,
    ThemeData theme,
  ) {
    final isSupported = bio.isDeviceSupported;
    final isFace = bio.hasFace && !bio.hasFingerprint;
    final iconData = isFace ? Icons.face_unlock_rounded : Icons.fingerprint_rounded;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : const Color(0xFF10B981).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      iconData,
                      size: 24,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.getText('biometric_lock'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        lang.getText('biometric_lock_subtitle'),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Switch
                Switch.adaptive(
                  value: bio.isBiometricEnabled,
                  activeTrackColor: const Color(0xFF10B981),
                  onChanged: isSupported
                      ? (value) async {
                          final reasonKey = value
                              ? 'biometric_enable_reason'
                              : 'biometric_disable_reason';
                          final success = await bio.toggleBiometricLock(
                            enable: value,
                            promptReason: lang.getText(reasonKey),
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            if (success) {
                              final msgKey = value
                                  ? 'biometric_lock_enabled_msg'
                                  : 'biometric_lock_disabled_msg';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline_rounded,
                                          color: Colors.white, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          lang.getText(msgKey),
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded,
                                          color: Colors.white, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          lang.getText('biometric_auth_failed'),
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                              );
                            }
                          }
                        }
                      : null,
                ),
              ],
            ),

            if (!isSupported) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lang.getText('biometric_not_supported'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Notifications & Alerts Card with master toggle, daily reminder timer, and budget warnings
  Widget _buildNotificationCard(
    BuildContext context,
    LanguageProvider lang,
    NotificationProvider notif,
    bool isDark,
    ThemeData theme,
  ) {
    final reminderFormatted = notif.reminderTime.format(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Master Toggle (Enable All Notifications)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_active_rounded,
                      size: 22,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.getText('enable_notifications'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 15.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lang.getText('enable_notifications_desc'),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch.adaptive(
                  value: notif.isNotificationsEnabled,
                  activeTrackColor: const Color(0xFFF59E0B),
                  onChanged: (value) async {
                    final granted = await notif.setNotificationsEnabled(value);
                    if (value && !granted && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(lang.getText('notification_permission_denied')),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // If notifications master toggle is ON, show sub-options
          if (notif.isNotificationsEnabled) ...[
            const Divider(height: 1, indent: 70),

            // 2. Daily Reminder Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white10
                          : const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.alarm_rounded,
                        size: 20,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.getText('daily_reminder'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lang.getText('daily_reminder_desc'),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white60 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch.adaptive(
                    value: notif.isDailyReminderEnabled,
                    activeTrackColor: const Color(0xFF8B5CF6),
                    onChanged: (val) {
                      notif.setDailyReminderEnabled(
                        val,
                        title: lang.getText('daily_reminder_title'),
                        body: lang.getText('daily_reminder_body'),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 3. Set Timer for Daily Reminder (Time Picker)
            if (notif.isDailyReminderEnabled) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(72, 0, 18, 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.getText('reminder_time'),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              reminderFormatted,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.edit_calendar_rounded, size: 14),
                        label: Text(
                          lang.getText('change_time'),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: notif.reminderTime,
                          );
                          if (picked != null && context.mounted) {
                            await notif.setReminderTime(
                              picked,
                              title: lang.getText('daily_reminder_title'),
                              body: lang.getText('daily_reminder_body'),
                            );
                            if (context.mounted) {
                              final isToday = notif.isReminderToday;
                              final scheduleWhen = isToday ? 'Today' : 'Tomorrow';
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline_rounded,
                                          color: Colors.white, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Daily reminder set for ${picked.format(context)} ($scheduleWhen)',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 3),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Divider(height: 1, indent: 70),

            // 4. Budget Warning Alerts Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white10
                          : AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.getText('budget_alerts'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lang.getText('budget_alerts_desc'),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white60 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch.adaptive(
                    value: notif.isBudgetAlertsEnabled,
                    activeTrackColor: AppColors.error,
                    onChanged: (val) => notif.setBudgetAlertsEnabled(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}
