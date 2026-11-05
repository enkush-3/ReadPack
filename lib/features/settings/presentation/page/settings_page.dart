import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/profile/widgets/profile_challenge_card.dart';
import 'package:readpack/features/profile/widgets/profile_edit_dialog.dart';
import 'package:readpack/features/quotes/presentation/phone_widget_sheet.dart';
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
      backgroundColor: colorScheme.surface,
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
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Section 1: Профайл & Бүртгэл (Profile & Account)
          _buildSectionHeader(
            'Профайл & Бүртгэл',
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildCard(
            colorScheme: colorScheme,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: profile.isGuest
                            ? colorScheme.surfaceContainerHighest
                            : null,
                        gradient: profile.isGuest
                            ? null
                            : LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.primary.withValues(alpha: 0.7),
                                ],
                              ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: profile.isGuest
                            ? Icon(Icons.person_outline_rounded,
                                color: colorScheme.primary)
                            : Text(
                                profile.name.isNotEmpty
                                    ? profile.name[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
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
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  profile.isGuest ? 'Зочин' : 'Бүртгэлтэй',
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
                                ? 'Нэвтэрч өөрийн бүртгэлийг үүсгээрэй'
                                : profile.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                    Icons.badge_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text(
                    'Профайл мэдээлэл засах',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Нэр болон уншлагын тохиргоог шинэчлэх',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => ProfileEditDialog.show(context, bookProvider),
                ),
                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Бүртгэлээс гарах',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Бүртгэлээс гарах уу?'),
                        content: const Text(
                            'Та гарвал зочин горимд шилжих болно.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Болих'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              bookProvider.logout();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Гарах',
                              style: TextStyle(color: Colors.redAccent),
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
                  title: const Text(
                    'Нэвтрэх / Бүртгүүлэх',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Өөрийн хувийн сан, лиг болон тэмдэглэлүүдээ хадгалах',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
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
            'Уншлагын зорилго & 2026 челленж',
            colorScheme,
          ),
          const SizedBox(height: 12),
          ProfileChallengeCard(bookProvider: bookProvider),
          const SizedBox(height: 16),
          _buildCard(
            colorScheme: colorScheme,
            children: [
              ListTile(
                leading: Icon(
                  Icons.tune_rounded,
                  color: colorScheme.primary,
                ),
                title: const Text(
                  'Зорилго & Сонирхол шинэчлэх',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Унших жанр, өдрийн минутын зорилгоо шинээр тодорхойлох',
                  style: TextStyle(fontSize: 12),
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Өдрийн зорилго:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${profile.dailyGoalMinutes} минут/өдөр',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [15, 30, 45, 60].map((mins) {
                        final isSel = profile.dailyGoalMinutes == mins;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              bookProvider.updateUserProfile(
                                dailyGoalMinutes: mins,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? colorScheme.primary
                                    : colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '$mins мин',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSel
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
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
                    const Text(
                      'Сонирхсон төрлүүд:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        'Бизнес',
                        'Хувь хүний хөгжил',
                        'Сэтгэл зүй',
                        'Уран зохиол',
                        'Түүх',
                        'Шинжлэх ухаан',
                      ].map((genre) {
                        final isFav = profile.favoriteGenres.contains(genre);
                        return GestureDetector(
                          onTap: () {
                            final current = List<String>.from(profile.favoriteGenres);
                            if (isFav) {
                              if (current.length > 1) current.remove(genre);
                            } else {
                              current.add(genre);
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
                                  ? colorScheme.primary.withValues(alpha: 0.15)
                                  : colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isFav
                                    ? colorScheme.primary
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
                                  genre,
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
            'Утасны дэлгэцийн виджет',
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildCard(
            colorScheme: colorScheme,
            children: [
              ListTile(
                leading: Icon(
                  Icons.widgets_rounded,
                  color: colorScheme.primary,
                ),
                title: const Text(
                  'Ишлэлийн виджет тохируулах',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Өдрийн ишлэл эсвэл хадгалсан ишлэлээ утасны дэлгэцэнд байршуулах',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => PhoneWidgetSheet.show(context),
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
