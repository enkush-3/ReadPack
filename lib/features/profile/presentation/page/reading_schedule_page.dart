import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class ReadingSchedulePage extends StatefulWidget {
  const ReadingSchedulePage({super.key});

  @override
  State<ReadingSchedulePage> createState() => _ReadingSchedulePageState();
}

class _ReadingSchedulePageState extends State<ReadingSchedulePage> {
  List<Map<String, dynamic>> _getWeekDays(
    AppLocalizations? l10n,
    List<int> weeklyMinutes,
  ) {
    final labels = [
      l10n?.t('home.days.mon') ?? 'Да',
      l10n?.t('home.days.tue') ?? 'Мя',
      l10n?.t('home.days.wed') ?? 'Лх',
      l10n?.t('home.days.thu') ?? 'Пү',
      l10n?.t('home.days.fri') ?? 'Ба',
      l10n?.t('home.days.sat') ?? 'Бя',
      l10n?.t('home.days.sun') ?? 'Ня',
    ];
    final todayIndex = (DateTime.now().weekday - 1).clamp(0, 6);
    return List.generate(7, (idx) {
      return {
        'day': labels[idx],
        'minutes': idx < weeklyMinutes.length ? weeklyMinutes[idx] : 30,
        'isToday': idx == todayIndex,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final profile = bookProvider.userProfile;
    final l10n = AppLocalizations.of(context);

    final title = l10n?.t('profile.habits_title') ?? 'Уншлагын хуваарь';
    final dailyGoal = profile.dailyGoalMinutes;
    final selectedHour = profile.reminderHour;
    final remindersEnabled = profile.remindersEnabled;
    final totalWeekly = profile.totalWeeklyMinutes;
    final weeklyTarget = (dailyGoal * 7).clamp(1, 10000);
    final goalPct = ((totalWeekly / weeklyTarget) * 100).round().clamp(0, 100);
    final minShort = l10n?.t('common.minutes_short') ?? 'мин';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: colorScheme.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Current Schedule Overview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.6),
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded,
                                size: 14, color: colorScheme.primary),
                            const SizedBox(width: 5),
                            Text(
                              l10n?.t('schedule.active_schedule') ??
                                  'Идэвхтэй хуваарь',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$selectedHour:00 - ${selectedHour + 1}:00',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n?.t('schedule.evening_routine') ??
                        'Таны оройн тогтмол уншлага',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (l10n?.t('schedule.routine_desc') ??
                            'Өдөрт {mins} минут унших зорилготой байна. Судалгаагаар өдөр бүр ижил цагт унших нь тархинд унших дадлыг 3 дахин хурдан суулгадаг.')
                        .replaceAll('{mins}', '$dailyGoal'),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Weekly Consistency Bar Chart
            Text(
              l10n?.t('schedule.weekly_activity') ??
                  '7 хоногийн уншлагын идэвх',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _getWeekDays(l10n, profile.weeklyMinutes).map((w) {
                      final minutes = w['minutes'] as int;
                      final isToday = w['isToday'] as bool;
                      final heightFraction = (minutes / 70).clamp(0.15, 1.0);

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$minutes$minShort',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? colorScheme.primary
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 26,
                            height: 92 * heightFraction,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isToday
                                    ? [
                                        colorScheme.primary,
                                        colorScheme.primary
                                            .withValues(alpha: 0.7),
                                      ]
                                    : [
                                        colorScheme.primary
                                            .withValues(alpha: 0.35),
                                        colorScheme.primary
                                            .withValues(alpha: 0.15),
                                      ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            w['day'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isToday
                                  ? colorScheme.primary
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Divider(
                      color:
                          colorScheme.outlineVariant.withValues(alpha: 0.2)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (l10n?.t('schedule.total_read') ??
                                'Нийт уншсан: {mins} минут')
                            .replaceAll('{mins}', '$totalWeekly'),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        (l10n?.t('schedule.goal_completion') ??
                                'Зорилго биелэлт: {pct}%')
                            .replaceAll('{pct}', '$goalPct'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Time of Day Distribution
            Text(
              l10n?.t('schedule.time_distribution') ??
                  'Унших цагийн хуваарилалт',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildTimeSlotItem(
              title: l10n?.t('schedule.slot_evening') ??
                  'Орой (18:00 - 23:00)',
              subtitle: l10n?.t('schedule.slot_evening_desc') ??
                  'Таны хамгийн идэвхтэй цаг 🔥',
              percentage: profile.eveningPercentage,
              icon: Icons.nightlight_round,
              isBest: true,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 10),
            _buildTimeSlotItem(
              title: l10n?.t('schedule.slot_afternoon') ??
                  'Өдөр (12:00 - 18:00)',
              subtitle: l10n?.t('schedule.slot_afternoon_desc') ??
                  'Ажлын завсарлагаанаар',
              percentage: profile.afternoonPercentage,
              icon: Icons.wb_sunny_rounded,
              isBest: false,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 10),
            _buildTimeSlotItem(
              title: l10n?.t('schedule.slot_morning') ??
                  'Өглөө (06:00 - 12:00)',
              subtitle: l10n?.t('schedule.slot_morning_desc') ??
                  'Эртэч уншлага',
              percentage: profile.morningPercentage,
              icon: Icons.coffee_rounded,
              isBest: false,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 10),
            _buildTimeSlotItem(
              title: l10n?.t('schedule.slot_night') ??
                  'Шөнө (23:00 - 06:00)',
              subtitle: l10n?.t('schedule.slot_night_desc') ??
                  'Орондоо унших',
              percentage: profile.nightPercentage,
              icon: Icons.bedtime_rounded,
              isBest: false,
              colorScheme: colorScheme,
            ),

            const SizedBox(height: 28),

            // 4. Reminder Time Selector
            Text(
              l10n?.t('schedule.daily_reminder_title') ??
                  'Өдөр тутмын уншлагын сануулга',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notifications_active_rounded,
                              size: 20, color: colorScheme.primary),
                          const SizedBox(width: 10),
                          Text(
                            l10n?.t('profile.daily_reminder') ??
                                'Унших цагийн сануулга',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: remindersEnabled,
                        onChanged: (v) {
                          bookProvider.updateReadingReminder(
                            remindersEnabled: v,
                          );
                        },
                      ),
                    ],
                  ),
                  if (remindersEnabled) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n?.t('schedule.select_reminder_time') ??
                          'Сануулах цаг сонгох:',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [18, 19, 20, 21, 22].map((hour) {
                        final isSel = selectedHour == hour;
                        return AnimatedPressable(
                          onTap: () => bookProvider.updateReadingReminder(
                            reminderHour: hour,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$hour:00',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSel
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface
                                        .withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotItem({
    required String title,
    required String subtitle,
    required double percentage,
    required IconData icon,
    required bool isBest,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isBest
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBest
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 18,
                  color: isBest
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.6)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isBest
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isBest ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(
                isBest ? colorScheme.primary : colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

