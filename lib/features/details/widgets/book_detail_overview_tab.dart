import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class BookDetailOverviewTab extends StatefulWidget {
  final Book currentBook;
  final AppLocalizations? l10n;

  const BookDetailOverviewTab({
    super.key,
    required this.currentBook,
    this.l10n,
  });

  @override
  State<BookDetailOverviewTab> createState() => _BookDetailOverviewTabState();
}

class _BookDetailOverviewTabState extends State<BookDetailOverviewTab> {
  bool _isDescriptionExpanded = false;

  Widget _buildAuthorCard(
    BuildContext context,
    Book currentBook,
    ColorScheme colorScheme,
    AppLocalizations? l10n,
  ) {
    final isEn = l10n?.locale.languageCode == 'en';
    String bio;
    if (currentBook.author.contains('Orwell')) {
      bio = isEn
          ? 'George Orwell (1903–1950) was a renowned English novelist, essayist, and critic, famed for "1984" and "Animal Farm".'
          : 'Жорж Орвелл (1903–1950) нь Английн нэрт зохиолч, сэтгүүлч, шүүмжлэгч. Түүний "1984" болон "Амьтны ферм" романууд нь 20-р зууны тоталитаризмын эсрэг хамгийн хүчирхэг бүтээлүүд юм.';
    } else if (currentBook.author.contains('Clear')) {
      bio = isEn
          ? 'James Clear is a bestselling author and keynote speaker on habits, decision-making, and continuous improvement.'
          : 'Жэймс Клир нь дадал зуршил, шийдвэр гаргалт, хувь хүний тасралтгүй хөгжлийн чиглэлээр дэлхийд хүлээн зөвшөөрөгдсөн зохиолч, илтгэгч юм.';
    } else if (currentBook.author.contains('Parrish')) {
      bio = isEn
          ? 'Shane Parrish is an entrepreneur, author, and the founder of Farnam Street, helping leaders make better decisions.'
          : 'Шейн Парриш нь "Farnam Street" платформыг үндэслэгч, шийдвэр гаргалт ба сэтгэлгээний загваруудын шилдэг эксперт юм.';
    } else if (currentBook.author.contains('Harari')) {
      bio = isEn
          ? 'Yuval Noah Harari is an Oxford-educated historian, philosopher, and bestselling author of Sapiens and Homo Deus.'
          : 'Ювал Ной Харари нь Оксфордын их сургуулийн түүхийн ухааны доктор, дэлхийн түүх ба ирээдүйн чиг хандлагыг тодорхойлогч философич юм.';
    } else {
      bio = isEn
          ? '${currentBook.author} is an internationally acclaimed author celebrated for insightful and transformative works.'
          : '${currentBook.author} нь олон улсын шилдэг бүтээлүүдээрээ уншигчдын талархлыг хүлээсэн нэр хүндтэй зохиолч юм.';
    }

    final allBooks = context.watch<BookProvider>().books;
    final relatedBooks = allBooks
        .where((b) =>
            b.id != currentBook.id &&
            (b.author.toLowerCase() == currentBook.author.toLowerCase() ||
                b.category.toLowerCase() == currentBook.category.toLowerCase()))
        .take(4)
        .toList();

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(currentBook.colorHex).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Color(currentBook.colorHex), width: 2),
                ),
                child: Center(
                  child: Text(
                    currentBook.author.isNotEmpty ? currentBook.author[0] : 'A',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(currentBook.colorHex),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentBook.author,
                      style: const TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n?.t('book.author_badge') ?? 'Зохиогчийн тухай',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bio,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          if (relatedBooks.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              l10n?.t('book.author_other_works', {'author': currentBook.author}) ??
                  '${currentBook.author} зохиогчийн бусад бүтээл:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: relatedBooks.map((b) {
                return AnimatedPressable(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      Routes.bookDetail,
                      arguments: b,
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 11,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          b.title,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = widget.l10n;
    final currentBook = widget.currentBook;

    final aboutText = l10n?.t('book.about') ?? 'Номын тухай';
    final readMoreText = l10n?.t('book.read_more') ?? 'Дэлгэрэнгүй унших';
    final showLessText = l10n?.t('book.show_less') ?? 'Хураангуйлах';
    final takeawaysText =
        l10n?.t('book.key_takeaways') ?? 'Гол санаанууд (Key Takeaways)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          aboutText,
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          currentBook.description,
          maxLines: _isDescriptionExpanded ? null : 4,
          overflow: _isDescriptionExpanded
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.75),
            height: 1.6,
          ),
        ),
        if (currentBook.description.length > 150)
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _isDescriptionExpanded ? showLessText : readMoreText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        if (currentBook.keyTakeaways.isNotEmpty) ...[
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      takeawaysText,
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...currentBook.keyTakeaways.map((takeaway) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6, right: 8),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            takeaway,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.8),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
        _buildAuthorCard(context, currentBook, colorScheme, l10n),
      ],
    );
  }
}
