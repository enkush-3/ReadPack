import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class ProfileGuestCard extends StatelessWidget {
  final BookProvider bookProvider;

  const ProfileGuestCard({
    super.key,
    required this.bookProvider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final features = [
      {
        'icon': Icons.emoji_events_rounded,
        'color': colorScheme.primary,
        'title': l10n?.t('profile.leaderboard') ??
            'Лидерборд & Долоо хоногийн лиг',
        'desc': l10n?.t('profile.guest_benefit_leaderboard_desc') ??
            'Бусад шилдэг уншигчидтай өрсөлдөж дэвших',
      },
      {
        'icon': Icons.bolt_rounded,
        'color': const Color(0xFF38BDF8),
        'title': l10n?.t('profile.level_title') ?? 'XP түвшин ба цол',
        'desc': l10n?.t('profile.guest_benefit_xp_desc') ??
            'Уншсан минут, ном бүрээрээ шагнал цуглуулах',
      },
      {
        'icon': Icons.local_fire_department_rounded,
        'color': Colors.deepOrangeAccent,
        'title': l10n?.t('profile.guest_benefit_streak') ??
            'Өдөр тутмын уншлагын цуврал (Streak)',
        'desc': l10n?.t('profile.guest_benefit_streak_desc') ??
            'Дадал зуршлаа таслалгүй хадгалах',
      },
      {
        'icon': Icons.cloud_done_rounded,
        'color': Colors.blueAccent,
        'title': l10n?.t('profile.guest_benefit_sync') ??
            'Төхөөрөмж хоорондын синк',
        'desc': l10n?.t('profile.guest_benefit_sync_desc') ??
            'Хадгалсан ном, тэмдэглэл, эшлэлүүдээ хадгалах',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.35),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.stars_rounded,
                  color: colorScheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.t('auth.welcome') ?? 'Тавтай морилно уу!',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n?.t('profile.guest_prompt') ??
                          'Бүртгэл үүсгэж уншлагын ахицаа хадгалаарай.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 14),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (f['color'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        f['icon'] as IconData,
                        size: 16,
                        color: f['color'] as Color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f['title'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            f['desc'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: AnimatedPressable(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.auth);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        l10n?.t('profile.login_signup') ?? 'Нэвтрэх / Бүртгүүлэх',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
