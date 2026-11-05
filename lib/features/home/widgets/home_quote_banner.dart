import 'package:flutter/material.dart';
import 'package:readpack/features/shared/widgets/quote_share_modal.dart';
import 'package:readpack/helper/translation.dart';

class HomeQuoteBanner extends StatelessWidget {
  const HomeQuoteBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final dailyQuoteTitle =
        l10n?.t('home.daily_quote_title') ?? 'Өдрийн эшлэл';
    final dailyQuote = l10n?.t('home.daily_quote') ??
        'Ном уншдаг хүн үхэхээсээ өмнө мянган амьдралаар амьдардаг.';
    final dailyQuoteAuthor =
        l10n?.t('home.daily_quote_author') ?? 'Жорж Р.Р. Мартин';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.6),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.format_quote_rounded,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dailyQuoteTitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        QuoteShareModal.show(
                          context,
                          quote: dailyQuote,
                          author: dailyQuoteAuthor,
                          bookTitle: 'ReadPack Daily',
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.share_rounded,
                              size: 13,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n?.t('quote_share.share') ?? 'Хуваалцах',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '"$dailyQuote"',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurface.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '— $dailyQuoteAuthor',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
