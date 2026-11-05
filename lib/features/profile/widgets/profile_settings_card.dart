import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';

class ProfileSettingsCard extends StatelessWidget {
  final BookProvider bookProvider;
  final ThemeProvider themeProvider;

  const ProfileSettingsCard({
    super.key,
    required this.bookProvider,
    required this.themeProvider,
  });

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n?.t('auth.logout') ?? 'Гарах',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            l10n?.t('profile.logout_confirm') ??
                'Та гарахдаа итгэлтэй байна уу?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n?.t('common.cancel') ?? 'Цуцлах'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                bookProvider.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n?.t('success.logout') ?? 'Амжилттай гарлаа',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(l10n?.t('auth.logout') ?? 'Гарах'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final profile = bookProvider.userProfile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10n?.t('profile.settings') ?? 'Тохиргоо',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.settings);
              },
              icon: const Icon(Icons.tune_rounded, size: 16),
              label: Text(
                l10n?.t('settings.manage') ?? 'Удирдах',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Material(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Theme Switch
              ListTile(
                leading: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('profile.dark_mode') ?? 'Харанхуй горим',
                ),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),

              // Language Switcher
              ListTile(
                leading: Icon(
                  Icons.language_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('profile.language') ?? 'Хэл (Language)',
                ),
                trailing: DropdownButton<String>(
                  value: themeProvider.locale.languageCode,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'mn', child: Text('Монгол')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (lang) {
                    if (lang != null) {
                      themeProvider.setLocale(Locale(lang));
                    }
                  },
                ),
              ),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),

              // Daily Reminder Toggle
              ListTile(
                leading: Icon(
                  Icons.notifications_active_outlined,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('profile.daily_reminder') ??
                      'Өдрийн уншлагын сануулга',
                ),
                trailing: Switch(
                  value: profile.notificationsEnabled,
                  onChanged: (val) {
                    bookProvider.updateUserProfile(notificationsEnabled: val);
                  },
                ),
              ),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),

              // Book Recommendations Toggle
              ListTile(
                leading: Icon(
                  Icons.recommend_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('profile.book_recommendations') ??
                      'Шинэ номын зөвлөмж',
                ),
                trailing: Switch(
                  value: profile.recommendationsEnabled,
                  onChanged: (val) {
                    bookProvider.updateUserProfile(
                      recommendationsEnabled: val,
                    );
                  },
                ),
              ),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),

              // Clear Cache Action
              ListTile(
                leading: Icon(
                  Icons.cleaning_services_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('profile.storage_cache') ?? 'Кэш цэвэрлэх',
                ),
                subtitle: const Text(
                  '14.2 MB',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  bookProvider.clearCache();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n?.t('profile.cache_cleared') ??
                            'Кэш амжилттай цэвэрлэгдлээ (14.2 MB чөлөөллөө)',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              if (!profile.isGuest) ...[
                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),

                // Logout Action
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    l10n?.t('profile.logout') ?? 'Гарах (Logout)',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
