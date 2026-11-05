import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class BookDetailReviewForm extends StatefulWidget {
  final Book currentBook;
  final AppLocalizations? l10n;

  const BookDetailReviewForm({
    super.key,
    required this.currentBook,
    this.l10n,
  });

  @override
  State<BookDetailReviewForm> createState() => _BookDetailReviewFormState();
}

class _BookDetailReviewFormState extends State<BookDetailReviewForm> {
  double _userRating = 5.0;
  late TextEditingController _nameController;
  late TextEditingController _commentController;
  bool _isReviewSubmitted = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submitInlineReview() {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    final userProfile = context.read<BookProvider>().userProfile;
    final userName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : userProfile.name;

    final newReview = BookReview(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      userName: userName,
      rating: _userRating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    context.read<BookProvider>().addReview(widget.currentBook.id, newReview);
    _commentController.clear();

    setState(() {
      _isReviewSubmitted = true;
    });

    final l10n = widget.l10n ?? AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.t('reviews.success') ?? 'Таны сэтгэгдэл амжилттай нэмэгдлээ!',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = widget.l10n ?? AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.t('reviews.write_review') ?? 'Сэтгэгдэл бичих',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  final star = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _userRating = star.toDouble());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        _userRating >= star
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          if (_isReviewSubmitted) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n?.t('reviews.success') ??
                          'Таны сэтгэгдэл амжилттай нэмэгдлээ!',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: l10n?.t('reviews.your_name_hint') ??
                  'Нэрээ оруулна уу (заавал биш)',
              hintStyle: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n?.t('reviews.your_comment_hint') ??
                  'Энэ номын талаар сэтгэгдлээ хуваалцаарай...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedPressable(
              onTap: _submitInlineReview,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send_rounded,
                        size: 14, color: colorScheme.onPrimary),
                    const SizedBox(width: 6),
                    Text(
                      l10n?.t('reviews.submit') ?? 'Сэтгэгдэл илгээх',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
