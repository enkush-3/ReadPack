import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
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
  late TextEditingController _commentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitInlineReview(BookReview? existingReview) {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    final userProfile = context.read<BookProvider>().userProfile;
    if (userProfile.isGuest) {
      Navigator.of(context).pushNamed(Routes.auth);
      return;
    }

    if (existingReview != null && _isEditing) {
      final updated = existingReview.copyWith(
        rating: _userRating,
        comment: comment,
      );
      context.read<BookProvider>().updateReview(widget.currentBook.id, updated);
      setState(() {
        _isEditing = false;
        _commentController.clear();
      });
    } else {
      final newReview = BookReview(
        id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
        userName: userProfile.name,
        rating: _userRating,
        comment: comment,
        createdAt: DateTime.now(),
      );
      context.read<BookProvider>().addReview(widget.currentBook.id, newReview);
      _commentController.clear();
      setState(() {});
    }
  }

  void _deleteUserReview(String reviewId) {
    context.read<BookProvider>().deleteReview(widget.currentBook.id, reviewId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.l10n?.t('reviews.deleted_success') ?? 'Сэтгэгдэл устгагдлаа.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildGuestPrompt(
    ColorScheme colorScheme,
    AppLocalizations? l10n,
  ) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.t('reviews.login_required_title') ??
                          'Сэтгэгдэл бичихийн тулд нэвтэрнэ үү',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n?.t('reviews.login_required_desc') ??
                          'Зөвхөн бүртгэлтэй хэрэглэгчид үнэлгээ, сэтгэгдэл үлдээх боломжтой.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedPressable(
            onTap: () {
              Navigator.of(context).pushNamed(Routes.auth);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  l10n?.t('reviews.login_action') ?? 'Нэвтрэх / Бүртгүүлэх',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = widget.l10n ?? AppLocalizations.of(context);
    final userProfile = context.watch<BookProvider>().userProfile;

    // If user is a guest, prompt to sign in before writing a review
    if (userProfile.isGuest) {
      return _buildGuestPrompt(colorScheme, l10n);
    }

    // Check if user already submitted a review
    final existingReview = widget.currentBook.reviews
        .where((r) => r.userName == userProfile.name)
        .firstOrNull;

    // Display existing review card with Edit & Delete actions
    if (existingReview != null && !_isEditing) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n?.t('reviews.your_review') ?? 'Таны сэтгэгдэл',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < existingReview.rating.floor()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: colorScheme.primary,
                      tooltip: l10n?.t('reviews.edit') ?? 'Засах',
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                          _commentController.text = existingReview.comment;
                          _userRating = existingReview.rating;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      color: colorScheme.error,
                      tooltip: l10n?.t('reviews.delete') ?? 'Устгах',
                      onPressed: () => _deleteUserReview(existingReview.id),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              existingReview.comment,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

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
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        colorScheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      userProfile.name.isNotEmpty
                          ? userProfile.name[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        l10n?.t('reviews.posting_as') ??
                            'Таны бүртгэлээр нийтлэгдэнэ',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
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
          const SizedBox(height: 14),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_isEditing) ...[
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _commentController.clear();
                    });
                  },
                  child: Text(
                    l10n?.t('common.cancel') ?? 'Болих',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              AnimatedPressable(
                onTap: () => _submitInlineReview(existingReview),
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
                      Icon(
                        _isEditing ? Icons.check_rounded : Icons.send_rounded,
                        size: 14,
                        color: colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isEditing
                            ? (l10n?.t('reviews.update') ?? 'Шинэчлэх')
                            : (l10n?.t('reviews.submit') ?? 'Сэтгэгдэл илгээх'),
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
            ],
          ),
        ],
      ),
    );
  }
}
