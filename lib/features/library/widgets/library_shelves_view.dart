import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/library/widgets/library_collection_dialogs.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/collection.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class LibraryShelvesView extends StatelessWidget {
  final BookProvider provider;

  const LibraryShelvesView({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final downloadedCollection = BookCollection(
      id: 'c_downloaded',
      name: l10n?.t('collection.downloaded_title') ?? 'Татсан',
      description: l10n?.t('collection.downloaded_desc') ??
          'Офлайн уншихаар татаж авсан номууд',
      icon: 'download',
      bookIds: provider.downloadedBookIds.toList(),
      createdAt: DateTime(2026, 1, 1),
    );

    final displayCollections = [
      downloadedCollection,
      ...provider.collections.where((c) => c.id != 'c_downloaded'),
    ];

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          AnimatedPressable(
            onTap: () => LibraryCollectionDialogs.showCreateCollectionDialog(
              context,
              provider,
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.t('collection.create_new_btn') ??
                        '+ Шинэ цуглуулга үүсгэх',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...displayCollections.map((coll) {
            final isDownloaded = coll.id == 'c_downloaded';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDownloaded
                    ? colorScheme.primary.withValues(alpha: 0.08)
                    : colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDownloaded
                      ? colorScheme.primary.withValues(alpha: 0.35)
                      : colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  onTap: () =>
                      LibraryCollectionDialogs.showCollectionDetailsSheet(
                    context,
                    provider,
                    coll,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDownloaded
                          ? colorScheme.primary.withValues(alpha: 0.18)
                          : colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isDownloaded
                          ? Icons.download_done_rounded
                          : LibraryCollectionDialogs.getCollectionIcon(
                              coll.icon),
                      color: colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        coll.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (isDownloaded) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n?.t('collection.offline_badge') ?? 'Офлайн',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (coll.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          coll.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        isDownloaded
                            ? '${(l10n?.t('collection.books_downloaded_count') ?? '{count} ном татсан').replaceAll('{count}', '${coll.bookIds.length}')} (${provider.totalDownloadedStorageMb.toStringAsFixed(1)} MB)'
                            : (l10n?.t('collection.books_contained_count') ??
                                    '{count} ном агуулсан')
                                .replaceAll(
                                    '{count}', '${coll.bookIds.length}'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  trailing: isDownloaded
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18),
                          color: colorScheme.error.withValues(alpha: 0.7),
                          onPressed: () {
                            provider.deleteCollection(coll.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n?.t('collection.deleted_toast') ??
                                      'Цуглуулга устгагдлаа',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                ),
              ),
            );
          }),
        ]),
      ),
    );
  }
}
