import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/library/widgets/library_collection_dialogs.dart';
import 'package:readpack/features/profile/widgets/profile_challenge_card.dart';
import 'package:readpack/features/profile/widgets/profile_edit_dialog.dart';
import 'package:readpack/features/quotes/presentation/phone_widget_sheet.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/user_stats.dart';
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
          // Section 1: Нэгтгэсэн Профайл & Бүртгэл (Merged Profile & Edit Card)
          _buildSectionHeader(
            l10n?.t('settings.profile_account') ?? 'Профайл & Бүртгэл',
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildMergedProfileCard(
            context: context,
            profile: profile,
            bookProvider: bookProvider,
            colorScheme: colorScheme,
            isDark: isDark,
            l10n: l10n,
          ),

          // Section 2: Уншлагын зорилго & 2026 челленж (Хэрэглэгчдэд зориулсан, зочинд нуух)
          if (!profile.isGuest) ...[
            const SizedBox(height: 24),
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
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
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
                            'label':
                                l10n?.t('settings.genre_history') ?? 'Түүх',
                          },
                          {
                            'key': 'Шинжлэх ухаан',
                            'label': l10n?.t('settings.genre_science') ??
                                'Шинжлэх ухаан',
                          },
                        ].map((genreMap) {
                          final genreKey = genreMap['key']!;
                          final genreLabel = genreMap['label']!;
                          final isFav =
                              profile.favoriteGenres.contains(genreKey);
                          return GestureDetector(
                            onTap: () {
                              final current =
                                  List<String>.from(profile.favoriteGenres);
                              if (isFav) {
                                if (current.length > 1) {
                                  current.remove(genreKey);
                                }
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
                                    ? colorScheme.primary
                                        .withValues(alpha: 0.12)
                                    : colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.32),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isFav
                                      ? colorScheme.primary
                                          .withValues(alpha: 0.5)
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
          ],

          // Section 3: Татсан номууд (Downloaded Books - Зочин болон хэрэглэгч хоёуланд нь)
          const SizedBox(height: 24),
          _buildSectionHeader(
            l10n?.t('library.downloaded') ?? 'Офлайн таталт',
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildCard(
            colorScheme: colorScheme,
            isDark: isDark,
            children: [
              ListTile(
                leading: Icon(
                  Icons.file_download_done_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('library.downloaded_books') ?? 'Татсан номууд',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${bookProvider.downloadedBookIds.length} ном төхөөрөмж дээр хадгалагдсан (${bookProvider.cacheSizeMb})',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  final downloadedCol = bookProvider.collections.firstWhere(
                    (c) => c.id == 'c_downloaded',
                    orElse: () => bookProvider.collections.first,
                  );
                  LibraryCollectionDialogs.showCollectionDetailsSheet(
                    context,
                    bookProvider,
                    downloadedCol,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 4: Харагдах байдал & Хэл (Appearance & Language)
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

          // Section 5: Мэдэгдэл & Зөвлөмж (Notifications & Recommendations)
          _buildSectionHeader(
            l10n?.t('settings.notifications') ?? 'Мэдэгдэл & Зөвлөмж',
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildCard(
            colorScheme: colorScheme,
            isDark: isDark,
            children: [
              SwitchListTile(
                secondary: Icon(
                  Icons.notifications_active_outlined,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('profile.daily_reminder') ??
                      'Өдрийн уншлагын сануулга',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                value: profile.notificationsEnabled,
                onChanged: (val) {
                  bookProvider.updateUserProfile(notificationsEnabled: val);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(val
                          ? 'Өдрийн сануулгыг асаалаа'
                          : 'Өдрийн сануулгыг унтраалаа'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.25),
              ),
              SwitchListTile(
                secondary: Icon(
                  Icons.recommend_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n?.t('profile.book_recommendations') ??
                      'Шинэ номын зөвлөмж',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                value: profile.recommendationsEnabled,
                onChanged: (val) {
                  bookProvider.updateUserProfile(recommendationsEnabled: val);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(val
                          ? 'Шинэ номын зөвлөмжийг асаалаа'
                          : 'Шинэ номын зөвлөмжийг унтраалаа'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 6: Утасны дэлгэцийн виджет (Phone Screen Widget)
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

          // Section 7: Гарах товч (Log Out) - ХАМГИЙН ДООР БАЙРШУУЛСАН
          if (!profile.isGuest) ...[
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: dangerColor,
                  side: BorderSide(
                    color: dangerColor.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(
                  l10n?.t('profile.logout') ?? 'Бүртгэлээс гарах',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onPressed: () =>
                    _confirmLogout(context, bookProvider, l10n, dangerColor),
              ),
            ),
          ],

          const SizedBox(height: 28),

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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMergedProfileCard({
    required BuildContext context,
    required UserProfile profile,
    required BookProvider bookProvider,
    required ColorScheme colorScheme,
    required bool isDark,
    required AppLocalizations? l10n,
  }) {
    if (profile.isGuest) {
      return _buildCard(
        colorScheme: colorScheme,
        isDark: isDark,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(
                      profile: profile,
                      size: 56,
                      fontSize: 22,
                      showEditBadge: false,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n?.t('profile.guest_user') ??
                                    'Зочин уншигч',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  l10n?.t('profile.guest_badge') ?? 'Зочин',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n?.t('settings.guest_subtitle') ??
                                'Татах, унших боломжтой. Бүртгэл үүсгэж датагаа хамгаалаарай.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: Text(
                      l10n?.t('settings.login_register') ??
                          'Нэвтрэх / Бүртгүүлэх',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.auth);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Registered user merged card
    return _buildCard(
      colorScheme: colorScheme,
      isDark: isDark,
      children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedPressable(
                    onTap: () => ProfileEditDialog.show(context, bookProvider),
                    child: UserAvatar(
                      profile: profile,
                      size: 60,
                      fontSize: 24,
                      showEditBadge: true,
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
                                profile.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n?.t('settings.registered_badge') ??
                                    'Бүртгэлтэй',
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
                          profile.username.isNotEmpty
                              ? profile.username
                              : '@${profile.email.split('@').first}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 13,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                profile.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.65),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (profile.phoneNumber.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 13,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                profile.phoneNumber,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.25),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.35),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                    label: Text(
                      l10n?.t('settings.edit_profile_action') ??
                          'Мэдээлэл засах',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () =>
                        ProfileEditDialog.show(context, bookProvider),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmLogout(
    BuildContext context,
    BookProvider bookProvider,
    AppLocalizations? l10n,
    Color dangerColor,
  ) {
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
