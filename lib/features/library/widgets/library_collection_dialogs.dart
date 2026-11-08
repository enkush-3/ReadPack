import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/models/collection.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/book_cover_image.dart';

class LibraryCollectionDialogs {
  static Future<bool> confirmAndDeleteDownload(
    BuildContext context,
    BookProvider provider,
    Book book,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          l10n?.t('library.delete_download_title') ?? 'Татсан номыг устгах уу?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n?.t('library.delete_download_desc', {'title': book.title}) ??
              'Та "${book.title}" номыг төхөөрөмжөөсөө устгахдаа итгэлтэй байна уу? Офлайн уншихын тулд дахин татаж авах шаардлагатай.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.t('common.cancel') ?? 'Болих'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.t('common.delete') ?? 'Устгах'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      provider.toggleDownloadBook(book.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.t('library.download_removed') ??
                  'Татсан ном төхөөрөмжөөс амжилттай устгагдлаа.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return true;
    }
    return false;
  }

  static IconData getCollectionIcon(String iconKey) {
    switch (iconKey) {
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      case 'lightbulb':
        return Icons.lightbulb_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'download':
      case 'download_done':
        return Icons.download_done_rounded;
      case 'bookmark':
      default:
        return Icons.bookmark_rounded;
    }
  }

  static void showCreateCollectionDialog(
    BuildContext context,
    BookProvider provider,
  ) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedIcon = 'bookmark';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colorScheme = Theme.of(context).colorScheme;
            final l10n = AppLocalizations.of(context);
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                l10n?.t('collection.create_new') ?? 'Шинэ цуглуулга үүсгэх',
                style: const TextStyle(
                  fontFamily: 'Serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: l10n?.t('collection.name_label') ??
                          'Цуглуулгын нэр',
                      hintText: l10n?.t('collection.name_hint') ??
                          'ж.нь 2026 онд унших номууд',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      labelText: l10n?.t('collection.desc_label') ??
                          'Тайлбар (Заавал биш)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.t('collection.select_icon') ?? 'Икон сонгох:',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      'bookmark',
                      'emoji_events',
                      'lightbulb',
                      'star',
                      'school',
                    ].map((iconKey) {
                      final isSelected = selectedIcon == iconKey;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() => selectedIcon = iconKey);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            getCollectionIcon(iconKey),
                            size: 20,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n?.t('common.cancel') ?? 'Цуцлах'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      provider.createCollection(
                        nameCtrl.text.trim(),
                        descCtrl.text.trim(),
                        icon: selectedIcon,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n?.t('collection.created_success') ??
                                'Шинэ цуглуулга амжилттай үүсгэгдлээ! (+30 XP)',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Text(l10n?.t('common.create') ?? 'Үүсгэх'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void showCollectionDetailsSheet(
    BuildContext context,
    BookProvider provider,
    BookCollection collection,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colorScheme = Theme.of(context).colorScheme;
        final l10n = AppLocalizations.of(context);
        final booksInCollection = provider.books
            .where((b) => collection.bookIds.contains(b.id))
            .toList();

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      collection.name,
                      style: const TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              if (collection.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  collection.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              AnimatedPressable(
                onTap: () {
                  showAddBookPicker(context, provider, collection);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded,
                          size: 18, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        l10n?.t('collection.add_books') ??
                            '+ Энэ цуглуулгад ном нэмэх',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: booksInCollection.isEmpty
                    ? Center(
                        child: Text(
                          l10n?.t('collection.empty') ??
                              'Цуглуулгад одоогоор ном ороогүй байна.',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: booksInCollection.length,
                        itemBuilder: (context, idx) {
                          final b = booksInCollection[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.of(context).pushNamed(
                                    Routes.bookDetail,
                                    arguments: b);
                              },
                              leading: BookCoverImage(
                                image: b.image,
                                colorHex: b.colorHex,
                                title: b.title,
                                author: b.author,
                                width: 36,
                                height: 48,
                                borderRadius: 6,
                              ),
                              title: Text(
                                b.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                b.author,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                ),
                                color: colorScheme.error
                                    .withValues(alpha: 0.8),
                                onPressed: () async {
                                  if (collection.id == 'c_downloaded') {
                                    final removed = await confirmAndDeleteDownload(
                                      context,
                                      provider,
                                      b,
                                    );
                                    if (removed && ctx.mounted) {
                                      Navigator.pop(ctx);
                                    }
                                  } else {
                                    provider.removeBookFromCollection(
                                      collection.id,
                                      b.id,
                                    );
                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                    }
                                  }
                                },
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

  static void showAddBookPicker(
    BuildContext context,
    BookProvider provider,
    BookCollection collection,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (pickerCtx) {
        return StatefulBuilder(
          builder: (context, setPickerState) {
            final colorScheme = Theme.of(context).colorScheme;
            final l10n = AppLocalizations.of(context);
            final currentColl = provider.collections.firstWhere(
              (c) => c.id == collection.id,
              orElse: () => collection,
            );
            final allBooks = provider.books;

            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n?.t('collection.select_books_to_add') ??
                            'Цуглуулгад ном сонгох',
                        style: const TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(pickerCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allBooks.length,
                      itemBuilder: (context, i) {
                        final b = allBooks[i];
                        final isIncluded = currentColl.bookIds.contains(b.id);
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          leading: BookCoverImage(
                            image: b.image,
                            colorHex: b.colorHex,
                            title: b.title,
                            author: b.author,
                            width: 34,
                            height: 48,
                            borderRadius: 6,
                          ),
                          title: Text(
                            b.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            b.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isIncluded
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isIncluded
                                  ? Icons.check_rounded
                                  : Icons.add_rounded,
                              size: 16,
                              color: isIncluded
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          onTap: () {
                            if (isIncluded) {
                              provider.removeBookFromCollection(
                                  collection.id, b.id);
                            } else {
                              provider.addBookToCollection(
                                  collection.id, b.id);
                            }
                            setPickerState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(pickerCtx),
                      child: Text(
                        l10n?.t('common.done') ?? 'Болсон',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
