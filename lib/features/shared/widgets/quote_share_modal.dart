import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readpack/helper/translation.dart';

class QuoteShareModal extends StatefulWidget {
  final String quote;
  final String author;
  final String bookTitle;

  const QuoteShareModal({
    super.key,
    required this.quote,
    required this.author,
    required this.bookTitle,
  });

  static void show(
    BuildContext context, {
    required String quote,
    required String author,
    required String bookTitle,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuoteShareModal(
        quote: quote,
        author: author,
        bookTitle: bookTitle,
      ),
    );
  }

  @override
  State<QuoteShareModal> createState() => _QuoteShareModalState();
}

class _QuoteShareModalState extends State<QuoteShareModal> {
  int _selectedGradientIndex = 0;

  static const List<List<Color>> _gradients = [
    // Deep Midnight
    [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
    // Sunset Glow
    [Color(0xFF831843), Color(0xFFBE185D), Color(0xFFF43F5E)],
    // Emerald Forest
    [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF10B981)],
    // Vintage Sepia
    [Color(0xFF78350F), Color(0xFF92400E), Color(0xFFD97706)],
    // Royal Indigo
    [Color(0xFF1E1B4B), Color(0xFF3730A3), Color(0xFF4F46E5)],
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    final modalTitle = l10n?.t('quote_share.title') ?? 'Эшлэл хуваалцах';
    final chooseThemeText =
        l10n?.t('quote_share.choose_theme') ?? 'Картын өнгө сонгох';
    final copyTextAction = l10n?.t('quote_share.copy_text') ?? 'Текст хуулах';
    final shareCardAction =
        l10n?.t('quote_share.share_card') ?? 'Instagram Story-д хуваалцах';
    final copiedSuccess =
        l10n?.t('reader.quote_copied') ?? 'Ишлэл амжилттай хуулагдлаа!';
    final sharedSuccess = l10n?.t('quote_share.shared_success') ??
        'Эшлэлийн карт сошиалд хуваалцахад бэлэн боллоо!';

    return Container(
      constraints: BoxConstraints(maxHeight: size.height * 0.9),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row
            Center(
              child: Text(
                modalTitle,
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Aesthetic Card Preview (Instagram Story / Post format)
            Center(
              child: Container(
                width: 310,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradients[_selectedGradientIndex],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _gradients[_selectedGradientIndex].first
                          .withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top App Branding
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_stories_rounded,
                                  color: Colors.white, size: 13),
                              SizedBox(width: 5),
                              Text(
                                'ReadPack Daily',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Quotation mark icon
                    Text(
                      '“',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 48,
                        height: 0.8,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // The Quote Text
                    Text(
                      widget.quote,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Divider line
                    Container(
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Author Signature
                    Text(
                      widget.author.isNotEmpty ? '— ${widget.author}' : '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Book Title
                    Text(
                      widget.bookTitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Gradient Palette Selector
            Text(
              chooseThemeText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_gradients.length, (index) {
                final isSelected = _selectedGradientIndex == index;
                final grad = _gradients[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedGradientIndex = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: grad,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : Colors.white,
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: grad.first.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 22),

            // Action Buttons
            Row(
              children: [
                // Copy Text Button
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  onPressed: () {
                    final fullText =
                        '“${widget.quote}”\n— ${widget.author} (${widget.bookTitle})\nvia ReadPack';
                    Clipboard.setData(ClipboardData(text: fullText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(copiedSuccess),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.copy_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        copyTextAction,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

                // Share Story Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final storyText =
                          '“${widget.quote}”\n— ${widget.author} (${widget.bookTitle})\n#ReadPack #BookQuote';
                      Clipboard.setData(ClipboardData(text: storyText));
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(sharedSuccess),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.share_rounded, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          shareCardAction,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
