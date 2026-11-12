import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/empty_state_view.dart';
import 'package:readpack/shared/widgets/error_state_view.dart';
import 'package:readpack/shared/widgets/skeleton_loader.dart';

class BookDetailChaptersTab extends StatelessWidget {
  final Book currentBook;
  final AppLocalizations? l10n;

  const BookDetailChaptersTab({
    super.key,
    required this.currentBook,
    this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final chaptersText = l10n?.t('book.chapters') ?? 'Бүлгүүд';
    final readableChapters = currentBook.chapters
        .asMap()
        .entries
        .where((entry) => entry.value.content.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          chaptersText,
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (readableChapters.isEmpty && bookProvider.isLoading)
          _buildLoadingState()
        else if (readableChapters.isEmpty && bookProvider.errorMessage != null)
          ErrorStateView(
            errorMessage: bookProvider.errorMessage!,
            onRetry: bookProvider.retryInitialization,
          )
        else if (readableChapters.isEmpty)
          EmptyStateView(
            icon: Icons.menu_book_rounded,
            title: l10n?.t('reader.no_chapters') ?? 'Унших бүлэг алга байна',
            message:
                l10n?.t('reader.no_chapters_desc') ??
                'Энэ номын бүрэн текст уншигчид байхгүй байна.',
          )
        else
          ...List.generate(readableChapters.length, (index) {
            final chapterEntry = readableChapters[index];
            final chapter = chapterEntry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.25,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      Routes.reader,
                      arguments: {
                        'book': currentBook,
                        'initialChapterIndex': chapterEntry.key,
                      },
                    );
                  },
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    chapter.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '~${chapter.estimatedMinutes} ${l10n?.t('book.minutes_read') ?? 'минут уншина'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Column(
      children: [
        SkeletonLoader(width: double.infinity, height: 64, borderRadius: 14),
        SizedBox(height: 12),
        SkeletonLoader(width: double.infinity, height: 64, borderRadius: 14),
        SizedBox(height: 12),
        SkeletonLoader(width: double.infinity, height: 64, borderRadius: 14),
      ],
    );
  }
}
