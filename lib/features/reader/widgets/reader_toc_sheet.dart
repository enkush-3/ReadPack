import 'package:flutter/material.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';

class ReaderTocSheet {
  static void show({
    required BuildContext context,
    required Book book,
    required int currentChapterIndex,
    required ValueChanged<int> onSelectChapter,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final l10n = AppLocalizations.of(ctx);
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n?.t('reader.chapters') ?? 'Гарчиг',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              if (book.chapters.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      l10n?.t('reader.no_chapters') ??
                          'Бүлгийн гарчиг байхгүй байна',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: book.chapters.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final chapter = book.chapters[index];
                      final isCurrent = index == currentChapterIndex;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          onSelectChapter(index);
                          Navigator.pop(ctx);
                        },
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          chapter.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.w500,
                            color: isCurrent
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                        trailing: Text(
                          '~${chapter.estimatedMinutes} ${l10n?.t('common.minutes_short') ?? 'мин'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
