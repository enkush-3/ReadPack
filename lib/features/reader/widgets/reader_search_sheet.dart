import 'package:flutter/material.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/inputfield.dart';

class ReaderSearchSheet {
  static void show({
    required BuildContext context,
    required Book book,
    required void Function(int chapterIndex) onSelectChapter,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _ReaderSearchSheetBody(
          book: book,
          onSelectChapter: onSelectChapter,
        );
      },
    );
  }
}

class _ReaderSearchSheetBody extends StatefulWidget {
  final Book book;
  final void Function(int chapterIndex) onSelectChapter;

  const _ReaderSearchSheetBody({
    required this.book,
    required this.onSelectChapter,
  });

  @override
  State<_ReaderSearchSheetBody> createState() => _ReaderSearchSheetBodyState();
}

class _ReaderSearchSheetBodyState extends State<_ReaderSearchSheetBody> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final List<Map<String, dynamic>> matches = [];
    if (_query.trim().length >= 2) {
      final q = _query.trim().toLowerCase();
      for (int cIdx = 0; cIdx < widget.book.chapters.length; cIdx++) {
        final ch = widget.book.chapters[cIdx];
        final paragraphs = ch.content.split('\n\n');
        for (final p in paragraphs) {
          if (p.toLowerCase().contains(q)) {
            final matchPos = p.toLowerCase().indexOf(q);
            final start = (matchPos - 40).clamp(0, p.length);
            final end = (matchPos + q.length + 60).clamp(0, p.length);
            final snippet = '...${p.substring(start, end).replaceAll('\n', ' ')}...';
            matches.add({
              'chapterIndex': cIdx,
              'chapterTitle': ch.title,
              'snippet': snippet,
            });
          }
        }
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.t('reader_ext.in_book_search') ?? 'Ном дотроос хайх',
                style: const TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InputField(
            controller: _searchCtrl,
            hint: l10n?.t('reader_ext.search_hint') ?? 'Түлхүүр үг, нэр томьёо хайх...',
            icon: Icons.search_rounded,
            onChanged: (val) {
              setState(() => _query = val);
            },
          ),
          const SizedBox(height: 12),
          if (_query.trim().length >= 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                matches.isEmpty
                    ? (l10n?.t('reader_ext.no_matches') ?? 'Илэрц олдсонгүй')
                    : (l10n?.t('reader_ext.matches_found', {'count': '${matches.length}'}) ??
                        '${matches.length} илэрц олдлоо'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: matches.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.find_in_page_outlined,
                          size: 44,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _query.trim().isEmpty
                              ? (l10n?.t('reader_ext.search_hint') ?? 'Түлхүүр үгээ оруулна уу')
                              : (l10n?.t('reader_ext.no_matches') ?? 'Илэрц олдсонгүй'),
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: matches.length,
                    itemBuilder: (context, i) {
                      final item = matches[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: isDark ? 0.3 : 0.4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          title: Text(
                            item['chapterTitle'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item['snippet'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.8),
                                height: 1.3,
                              ),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            widget.onSelectChapter(
                                item['chapterIndex'] as int);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
