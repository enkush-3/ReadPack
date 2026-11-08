import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/user_avatar.dart';

class ProfileEditDialog {
  ProfileEditDialog._();

  static void show(BuildContext context, BookProvider bookProvider) {
    if (bookProvider.userProfile.isGuest) return;
    final nameCtrl =
        TextEditingController(text: bookProvider.userProfile.name);
    final customAvatarCtrl = TextEditingController(
      text: bookProvider.userProfile.avatarUrl.startsWith('http')
          ? bookProvider.userProfile.avatarUrl
          : '',
    );
    String selectedAvatar = bookProvider.userProfile.avatarUrl;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            final colorScheme = Theme.of(dialogContext).colorScheme;
            final previewProfile = bookProvider.userProfile.copyWith(
              name: nameCtrl.text.trim().isNotEmpty
                  ? nameCtrl.text.trim()
                  : bookProvider.userProfile.name,
              avatarUrl: selectedAvatar,
            );

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(dialogContext).size.height * 0.88,
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(dialogContext).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n?.t('profile.edit_profile') ?? 'Профайл засах',
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Avatar Preview & Selector
                    Center(
                      child: Column(
                        children: [
                          UserAvatar(
                            profile: previewProfile,
                            size: 72,
                            fontSize: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n?.t('profile.choose_avatar') ??
                                'Профайл зураг сонгох',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 58,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: UserAvatar.presetAvatars.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, idx) {
                          final item = UserAvatar.presetAvatars[idx];
                          final id = item['id']!;
                          final isSelected = selectedAvatar == id;
                          final tempProfile =
                              previewProfile.copyWith(avatarUrl: id);
                          return AnimatedPressable(
                            onTap: () {
                              setModalState(() {
                                selectedAvatar = id;
                                if (id.startsWith('http')) {
                                  customAvatarCtrl.text = id;
                                } else {
                                  customAvatarCtrl.clear();
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: UserAvatar(
                                profile: tempProfile,
                                size: 46,
                                fontSize: 18,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: customAvatarCtrl,
                      decoration: InputDecoration(
                        labelText: l10n?.t('profile.avatar_url_label') ??
                            'Зургийн линк (заавал биш)',
                        hintText: 'https://...',
                        prefixIcon:
                            const Icon(Icons.link_rounded, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                      onChanged: (val) {
                        if (val.trim().startsWith('http')) {
                          setModalState(() => selectedAvatar = val.trim());
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        labelText: l10n?.t('auth.full_name_label') ?? 'Нэр',
                        prefixIcon:
                            const Icon(Icons.person_outline_rounded, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(l10n?.t('common.cancel') ?? 'Болих'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final newName = nameCtrl.text.trim();
                              if (newName.isNotEmpty) {
                                bookProvider.updateUserProfile(
                                  name: newName,
                                  avatarUrl: selectedAvatar,
                                );
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n?.t('profile.updated') ??
                                          'Профайл амжилттай шинэчлэгдлээ',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Text(l10n?.t('common.save') ?? 'Хадгалах'),
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
