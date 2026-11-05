import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/shared/widgets/quote_share_modal.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/models/bookmark.dart';

class ReaderBookmarkModal {
  static void show({
    required BuildContext context,
    required String paragraphText,
    required Book book,
    required int currentChapterIndex,
    required double scrollProgress,
  }) {
    final noteCtrl = TextEditingController();
    int selectedColorHex = 0xFFFFD54F; // Gold default
    final l10n = AppLocalizations.of(context);

    final colors = [
      {'name': l10n?.t('reader.color_yellow') ?? 'Шар', 'hex': 0xFFFFD54F},
      {'name': l10n?.t('reader.color_green') ?? 'Ногоон', 'hex': 0xFF81C784},
      {'name': l10n?.t('reader.color_blue') ?? 'Цэнхэр', 'hex': 0xFF64B5F6},
      {'name': l10n?.t('reader.color_pink') ?? 'Ягаан', 'hex': 0xFFFF8A80},
      {'name': l10n?.t('reader.color_purple') ?? 'Нил', 'hex': 0xFFBA68C8},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final colorScheme = Theme.of(modalContext).colorScheme;
            return Container(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n?.t('reader.save_quote') ??
                              'Ишлэл & Тэмдэглэл хадгалах',
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: paragraphText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n?.t('reader.quote_copied') ??
                                    'Ишлэл хуулагдлаа!'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Selected text card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(selectedColorHex).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: Color(selectedColorHex),
                            width: 4,
                          ),
                        ),
                      ),
                      child: Text(
                        paragraphText.length > 200
                            ? '${paragraphText.substring(0, 200)}...'
                            : paragraphText,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurface,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n?.t('reader.highlight_color') ?? 'Тодруулах өнгө',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: colors.map((c) {
                        final hex = c['hex'] as int;
                        final isChosen = selectedColorHex == hex;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() => selectedColorHex = hex);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Color(hex),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isChosen
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: isChosen
                                ? const Icon(Icons.check,
                                    size: 18, color: Colors.black87)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteCtrl,
                      decoration: InputDecoration(
                        labelText: l10n?.t('reader.personal_note') ??
                            'Хувийн тэмдэглэл (заавал биш)',
                        hintText: l10n?.t('reader.note_hint') ??
                            'Энэ хэсгийн талаар юу бодогдов?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: BorderSide(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.5),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              QuoteShareModal.show(
                                context,
                                quote: paragraphText,
                                author: book.author,
                                bookTitle: book.title,
                              );
                            },
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.share_rounded, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n?.t('quote_share.title') ??
                                        'Карт үүсгэх',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              final chapterTitle = book.chapters.isNotEmpty
                                  ? book.chapters[currentChapterIndex].title
                                  : '${l10n?.t('reader.chapter') ?? 'Бүлэг'} 1';
                              final newBookmark = Bookmark(
                                id: 'bm_${DateTime.now().millisecondsSinceEpoch}',
                                bookId: book.id,
                                bookTitle: book.title,
                                chapterTitle: chapterTitle,
                                pageNumber:
                                    ((scrollProgress * book.pages).toInt() + 1),
                                quote: paragraphText.length > 200
                                    ? '${paragraphText.substring(0, 200)}...'
                                    : paragraphText,
                                note: noteCtrl.text.trim().isEmpty
                                    ? (l10n?.t('reader.personal_note') ??
                                        'Уншигчийн тэмдэглэл')
                                    : noteCtrl.text.trim(),
                                colorHex: selectedColorHex,
                                createdAt: DateTime.now(),
                              );
                              context
                                  .read<BookProvider>()
                                  .addBookmark(newBookmark);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      l10n?.t('reader.bookmark_added') ??
                                          'Ишлэл таны Сан руу хадгалагдлаа!'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Text(
                              l10n?.t('reader.save_quote') ?? 'Ишлэл хадгалах',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
