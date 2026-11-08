import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/profile/widgets/profile_challenge_card.dart';
import 'package:readpack/features/profile/widgets/profile_edit_dialog.dart';
import 'package:readpack/features/quotes/presentation/phone_widget_sheet.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/user_avatar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    final profile = bookProvider.userProfile;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final dangerColor =
        isDark ? const Color(0xFFF87171) : const Color(0xFFB84A4A);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: Text(
          l10n?.t('profile.settings') ?? 'Тохиргоо',
          style: TextStyle(
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Section 1: Профайл & Бүртгэл (Profile & Account)
          _buildSectionHeader(
            l10n?.t('settings.profile_account') ?? 'Профайл & Бүртгэл',
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildCard(
            colorScheme: colorScheme,
            isDark: isDark,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    AnimatedPressable(
                      onTap: profile.isGuest
                          ? null
                          : () => ProfileEditDialog.show(context, bookProvider),
                      child: UserAvatar(
                        profile: profile,
                        size: 56,
                        fontSize: 22,
                        showEditBadge: !profile.isGuest,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  profile.isGuest
                                      ? (l10n?.t('profile.guest_user') ??
                                          'Зочин уншигч')
                                      : profile.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  profile.isGuest
                                      ? (l10n?.t('profile.guest_badge') ??
                                          'Зочин')
                                      : (l10n?.t('settings.registered_badge') ??
                                          'Бүртгэлтэй'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.isGuest
                                ? (l10n?.t('settings.guest_subtitle') ??
                                    'Нэвтэрч өөрийн бүртгэлийг үүсгээрэй')
                                : profile.email,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.25),
              ),
              if (!profile.isGuest) ...[
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    l10n?.t('settings.edit_profile_title') ??
                        'Профайл зураг & мэдээлэл засах',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    l10n?.t('settings.edit_profile_sub') ??
                        'Зураг, нэр болон уншлагын тохиргоог шинэчлэх',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => ProfileEditDialog.show(context, bookProvider),
                ),
                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
                ListTile(
                  leading: Icon(
                    Icons.logout_rounded,
                    color: dangerColor,
                  ),
                  title: Text(
                    l10n?.t('profile.logout') ?? 'Бүртгэлээс гарах',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: dangerColor,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n?.t('settings.logout_confirm_title') ??
                            'Бүртгэлээс гарах уу?'),
                        content: Text(l10n?.t('settings.logout_confirm_desc') ??
                            'Та гарвал зочин горимд шилжих болно.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(l10n?.t('common.cancel') ?? 'Болих'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              bookProvider.logout();
                              Navigator.pop(context);
                            },
                            child: Text(
                              l10n?.t('profile.logout') ?? 'Гарах',
                              style: TextStyle(color: dangerColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ] else ...[
                ListTile(
                  leading: Icon(
                    Icons.login_rounded,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    l10n?.t('settings.login_register') ??
                        'Нэвтрэх / Бүртгүүлэх',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    l10n?.t('settings.login_register_sub') ??
                        'Өөрийн хувийн сан, лиг болон тэмдэглэлүүдээ хадгалах',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.auth);
                  },
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Section 2: Уншлагын зорилго & 2026 челленж
          _buildSectionHeader(
            l10n?.t('settings.goals_and_challenge') ??
                'Уншлагын зорилго & 2026 челленж',
            colorScheme,
          ),
          const SizedBox(height: 12),
          ProfileChallengeCard(bookProvider: bookProvider),
          const SizedBox(height: 16),
          _buildCard(
            colorScheme: colorScheme,
            isDark: isDark,
            children: [
              ListTile(
                leading: Icon(
                  Icons.tune_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('settings.update_goals_interests') ??
                      'Зорилго & Сонирхол шинэчлэх',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  l10n?.t('settings.update_goals_interests_sub') ??
                      'Унших жанр, өдрийн минутын зорилгоо шинээр тодорхойлох',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.onboarding);
                },
              ),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.25),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.t('settings.favorite_genres') ??
                          'Сонирхсон төрлүүд:',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        {
                          'key': 'Бизнес',
                          'label':
                              l10n?.t('settings.genre_business') ?? 'Бизнес',
                        },
                        {
                          'key': 'Хувь хүний хөгжил',
                          'label': l10n?.t('settings.genre_self_help') ??
                              'Хувь хүний хөгжил',
                        },
                        {
                          'key': 'Сэтгэл зүй',
                          'label': l10n?.t('settings.genre_psychology') ??
                              'Сэтгэл зүй',
                        },
                        {
                          'key': 'Уран зохиол',
                          'label': l10n?.t('settings.genre_fiction') ??
                              'Уран зохиол',
                        },
                        {
                          'key': 'Түүх',
                          'label': l10n?.t('settings.genre_history') ?? 'Түүх',
                        },
                        {
                          'key': 'Шинжлэх ухаан',
                          'label': l10n?.t('settings.genre_science') ??
                              'Шинжлэх ухаан',
                        },
                      ].map((genreMap) {
                        final genreKey = genreMap['key']!;
                        final genreLabel = genreMap['label']!;
                        final isFav = profile.favoriteGenres.contains(genreKey);
                        return GestureDetector(
                          onTap: () {
                            final current =
                                List<String>.from(profile.favoriteGenres);
                            if (isFav) {
                              if (current.length > 1) current.remove(genreKey);
                            } else {
                              current.add(genreKey);
                            }
                            bookProvider.updateUserProfile(
                              favoriteGenres: current,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isFav
                                  ? colorScheme.primary.withValues(alpha: 0.12)
                                  : colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.32),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isFav
                                    ? colorScheme.primary.withValues(alpha: 0.5)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isFav) ...[
                                  Icon(Icons.check,
                                      size: 12, color: colorScheme.primary),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  genreLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isFav
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isFav
                                        ? colorScheme.primary
                                        : colorScheme.onSurface
                                            .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 3: Харагдах байдал & Хэл (Appearance & Language)
          _buildSectionHeader(
            l10n?.t('settings.appearance') ?? 'Харагдах байдал & Хэл',
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildCard(
            colorScheme: colorScheme,
            isDark: isDark,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          themeProvider.themeMode == ThemeMode.system
                              ? Icons.brightness_auto_rounded
                              : (themeProvider.isDarkMode
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded),
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n?.t('settings.theme_mode_title') ??
                              'Өнгөний горим (Theme)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildThemeModeChip(
                          label: l10n?.t('settings.theme_system') ?? 'Систем',
                          icon: Icons.brightness_auto_rounded,
                          isSelected:
                              themeProvider.themeMode == ThemeMode.system,
                          onTap: () =>
                              themeProvider.setThemeMode(ThemeMode.system),
                          colorScheme: colorScheme,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildThemeModeChip(
                          label: l10n?.t('settings.theme_light') ?? 'Цайвар',
                          icon: Icons.light_mode_rounded,
                          isSelected:
                              themeProvider.themeMode == ThemeMode.light,
                          onTap: () =>
                              themeProvider.setThemeMode(ThemeMode.light),
                          colorScheme: colorScheme,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildThemeModeChip(
                          label: l10n?.t('settings.theme_dark') ?? 'Харанхуй',
                          icon: Icons.dark_mode_rounded,
                          isSelected: themeProvider.themeMode == ThemeMode.dark,
                          onTap: () =>
                              themeProvider.setThemeMode(ThemeMode.dark),
                          colorScheme: colorScheme,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.25),
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

          // Section 4: Мэдэгдэл & Зөвлөмж (Notifications & Recommendations)
          _buildSectionHeader(
            l10n?.t('settings.notifications') ?? 'Мэдэгдэл & Зөвлөмж',
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildCard(
            colorScheme: colorScheme,
            isDark: isDark,
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
                color: colorScheme.outlineVariant.withValues(alpha: 0.25),
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

          // Section 5: Утасны дэлгэцийн виджет (Phone Screen Widget)
          _buildSectionHeader(
            l10n?.t('settings.phone_widget_section') ??
                'Утасны дэлгэцийн виджет',
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildCard(
            colorScheme: colorScheme,
            isDark: isDark,
            children: [
              ListTile(
                leading: Icon(
                  Icons.widgets_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('settings.configure_widget') ??
                      'Ишлэлийн виджет тохируулах',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  l10n?.t('settings.configure_widget_sub') ??
                      'Өдрийн ишлэл эсвэл хадгалсан ишлэлээ утасны дэлгэцэнд байршуулах',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => PhoneWidgetSheet.show(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 6: Санах ой & Кэш (Storage & Cache)
          _buildSectionHeader(
            l10n?.t('settings.storage') ?? 'Санах ой & Кэш',
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildCard(
            colorScheme: colorScheme,
            isDark: isDark,
            children: [
              ListTile(
                leading: Icon(
                  Icons.cleaning_services_outlined,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('profile.clear_cache') ?? 'Кэш цэвэрлэх',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${bookProvider.downloadedBookIds.length} ном офлайнаар хадгалагдсан (${bookProvider.cacheSizeMb})',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: TextButton(
                  onPressed: bookProvider.downloadedBookIds.isEmpty
                      ? null
                      : () {
                          bookProvider.clearCache();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n?.t('profile.cache_cleared') ??
                                    'Кэш амжилттай цэвэрлэгдлээ',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                  child: Text(l10n?.t('common.clear') ?? 'Арилгах'),
                ),
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

  Widget _buildThemeModeChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return Expanded(
      child: AnimatedPressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? colorScheme.primary
                    : colorScheme.primary.withValues(alpha: 0.14))
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.65)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? (isDark ? colorScheme.onPrimary : colorScheme.primary)
                    : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? colorScheme.onPrimary : colorScheme.primary)
                        : colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildCard({
    required ColorScheme colorScheme,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Material(
      color: isDark
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.25)
          : colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outlineVariant
              .withValues(alpha: isDark ? 0.3 : 0.45),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
