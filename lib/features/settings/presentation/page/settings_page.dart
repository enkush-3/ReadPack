import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/helper/translation.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    final profile = bookProvider.userProfile;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.t('profile.settings') ?? 'Тохиргоо',
          style: const TextStyle(
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Section: General Preferences
          _buildSectionHeader(
            l10n?.t('settings.appearance') ?? 'Харагдах байдал & Хэл',
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildCard(
            colorScheme: colorScheme,
            children: [
              ListTile(
                leading: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('profile.dark_mode') ?? 'Харанхуй горим',
                  style: const TextStyle(fontWeight: FontWeight.w500),
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
              ListTile(
                leading: Icon(
                  Icons.language_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('profile.language') ?? 'Хэл (Language)',
                  style: const TextStyle(fontWeight: FontWeight.w500),
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
            ],
          ),

          const SizedBox(height: 24),

          // Section: Notifications
          _buildSectionHeader(
            l10n?.t('settings.notifications') ?? 'Мэдэгдэл & Зөвлөмж',
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildCard(
            colorScheme: colorScheme,
            children: [
              ListTile(
                leading: Icon(
                  Icons.notifications_active_outlined,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('profile.daily_reminder') ??
                      'Өдрийн уншлагын сануулга',
                  style: const TextStyle(fontWeight: FontWeight.w500),
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
              ListTile(
                leading: Icon(
                  Icons.recommend_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('profile.book_recommendations') ??
                      'Шинэ номын зөвлөмж',
                  style: const TextStyle(fontWeight: FontWeight.w500),
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
            ],
          ),

          const SizedBox(height: 24),

          // Section: Storage & Cache
          _buildSectionHeader(
            l10n?.t('settings.storage') ?? 'Хадгалах сан',
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildCard(
            colorScheme: colorScheme,
            children: [
              ListTile(
                leading: Icon(
                  Icons.cleaning_services_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('profile.storage_cache') ?? 'Кэш цэвэрлэх',
                  style: const TextStyle(fontWeight: FontWeight.w500),
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
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Version & copyright info
          Center(
            child: Column(
              children: [
                Text(
                  'ReadPack v1.2.0',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2026 ReadPack. All rights reserved.',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCard({
    required ColorScheme colorScheme,
    required List<Widget> children,
  }) {
    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
