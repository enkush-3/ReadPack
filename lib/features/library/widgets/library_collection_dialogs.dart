import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/models/collection.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class LibraryCollectionDialogs {
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
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Шинэ цуглуулга үүсгэх',
                style: TextStyle(
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
                    decoration: const InputDecoration(
                      labelText: 'Цуглуулгын нэр',
                      hintText: 'ж.нь 2026 онд унших номууд',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Тайлбар (Заавал биш)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Икон сонгох:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                  child: const Text('Цуцлах'),
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
                        const SnackBar(
                          content: Text(
                            'Шинэ цуглуулга амжилттай үүсгэгдлээ! (+30 XP)',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('Үүсгэх'),
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
                              leading: Container(
                                width: 36,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Color(b.colorHex),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    b.title.isNotEmpty ? b.title[0] : '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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
                                  Icons.remove_circle_outline,
                                  size: 18,
                                ),
                                color: colorScheme.error
                                    .withValues(alpha: 0.7),
                                onPressed: () {
                                  provider.removeBookFromCollection(
                                    collection.id,
                                    b.id,
                                  );
                                  Navigator.pop(ctx);
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
      backgroundColor: Colors.transparent,
      builder: (pickerCtx) {
        final colorScheme = Theme.of(context).colorScheme;
        final availableBooks = provider.books
            .where((b) => !collection.bookIds.contains(b.id))
            .toList();

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Цуглуулгад нэмэх номоо сонгоно уу',
                style:
                    TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: availableBooks.length,
                  itemBuilder: (context, i) {
                    final b = availableBooks[i];
                    return ListTile(
                      title: Text(
                        b.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle:
                          Text(b.author, style: const TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.add_circle_outline_rounded),
                      onTap: () {
                        provider.addBookToCollection(collection.id, b.id);
                        Navigator.pop(pickerCtx);
                        Navigator.pop(context);
                      },
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
