import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readpact/pages/auth/auth.dart';

import '../../widgets/common/info_shell.dart';
import '../../widgets/common/profile_edit.dart';
import '../../widgets/navigation/page_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});



  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'Enkush';
  String _userEmail = 'enkush@example.com';

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          PageHeader(title: 'Профайл'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  _buildProfileCard(colorScheme),
                  const SizedBox(height: 24),
                  _buildStatsRow(colorScheme),
                  const SizedBox(height: 24),
                  _buildSection(
                    colorScheme,
                    title: 'Тохиргоо',
                    children: [
                      _SettingsTile(
                        icon: Icons.notifications_rounded,
                        label: 'Мэдэгдэл',
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (v) => setState(() => _notificationsEnabled = v),
                          activeThumbColor: colorScheme.primary,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.dark_mode_rounded,
                        label: 'Шөнийн горим',
                        trailing: Switch(
                          value: _darkModeEnabled,
                          onChanged: (v) => setState(() => _darkModeEnabled = v),
                          activeThumbColor: colorScheme.primary,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        label: 'Хэл',
                        trailing: Text(
                          'Монгол',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    colorScheme,
                    title: 'Тусламж',
                    children: [
                      _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Тусламж, FAQ',
                        onTap: () {
                          InfoBottomSheet.show(
                            context: context,
                            title: 'Тусламж, FAQ',
                            content: _buildHelpContent(colorScheme),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Нууцлалын бодлого',
                        onTap: () {
                          InfoBottomSheet.show(
                            context: context,
                            title: 'Нууцлалын бодлого',
                            content: _buildPrivacyContent(colorScheme),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        label: 'Аппликейшны тухай',
                        trailing: Text(
                          'v1.0.0',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          InfoBottomSheet.show(
                            context: context,
                            title: 'Аппликейшны тухай',
                            content: _buildAboutContent(colorScheme),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showLogoutDialog,
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text('Гарах'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
              ),
              child: Center(
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userEmail,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        SizedBox(width: 2),
                        Text(
                          'Premium гишүүн',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showEditProfileSheet(colorScheme),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(ColorScheme colorScheme) {
    EditProfileBottomSheet.show(
      context: context,
      initialName: _userName,
      initialEmail: _userEmail,
      onSave: (name, email, password) {
        setState(() {
          _userName = name;
          _userEmail = email;
        });

        if (password != null) {
          debugPrint('Нууц үг шинэчлэгдлээ');
        }

        debugPrint('Нэр: $name, Имэйл: $email');
      },
    );
  }

  Widget _buildStatsRow(ColorScheme colorScheme) {
    final stats = [
      {'value': '24', 'label': 'Уншсан'},
      {'value': '8', 'label': 'Уншиж буй'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: stats.map((stat) {
            return Expanded(
              child: Column(
                children: [
                  Text(
                    stat['value']!,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat['label']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSection(
      ColorScheme colorScheme, {
        required String title,
        required List<Widget> children,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Гарах уу?'),
        content: const Text('Та аппликейшнээс гарахдаа итгэлтэй байна уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Цуцлах'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthPages(),
                ),
                    (route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Амжилттай гарлаа'),
                    ],
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Гарах'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _buildHelpContent(ColorScheme colorScheme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FAQItem(
        question: 'Номыг хэрхэн унших вэ?',
        answer: 'Номын дэлгэрэнгүй хуудас руу орж, "Унших" товчийг дарна уу. Ном онлайн болон offline горимд унших боломжтой.',
      ),
      const SizedBox(height: 16),
      _FAQItem(
        question: 'Номыг хэрхэн татаж авах вэ?',
        answer: 'Номын дэлгэрэнгүй хуудас дээрх "Татаж авах" товчийг дарж, offline унших боломжтой.',
      ),
      const SizedBox(height: 16),
      _FAQItem(
        question: 'Би өөрийн уншсан номыг хэрхэн харах вэ?',
        answer: '"Хадгалсан" хуудас руу орж, "Уншиж буй" эсвэл "Дууссан" фильтрүүдийг ашиглана уу.',
      ),
      const SizedBox(height: 16),
      _FAQItem(
        question: 'Нууц үгээ мартсан бол яах вэ?',
        answer: 'Нэвтрэх хуудас дээрх "Нууц үг мартсан уу?" холбоосыг дарж, имэйл хаягаараа нууц үгээ сэргээх боломжтой.',
      ),
    ],
  );
}

Widget _buildPrivacyContent(ColorScheme colorScheme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Өгөгдөл цуглуулах',
        style: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Бид зөвхөн таны аппликейшныг ашиглахад шаардлагатай мэдээллийг цуглуулдаг. Үүнд: нэр, имэйл хаяг, уншсан номын түүх.',
        style: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          height: 1.6,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        'Өгөгдөл хадгалах',
        style: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Таны өгөгдлийг бид шифрлэгдсэн сервер дээр хадгалдаг бөгөөд гуравдагч этгээдтэй хуваалцдаггүй.',
        style: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          height: 1.6,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        'Хувийн эрх',
        style: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Та өөрийн өгөгдлийг хэзээ ч устгах, засварлах эрхтэй. Профайл хуудаснаас эдгээр үйлдлийг хийх боломжтой.',
        style: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          height: 1.6,
        ),
      ),
    ],
  );
}

Widget _buildAboutContent(ColorScheme colorScheme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 20),

      Center(
        child: Text(
          'ReadPact',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      const SizedBox(height: 4),
      Center(
        child: Text(
          'v1.0.0',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
      const SizedBox(height: 24),

      Text(
        'ReadPact бол таны дуртай номуудыг унших, хадгалах, хуваалцах боломжийг олгодог орчин үеийн номын аппликейшн юм.',
        style: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),

      Text(
        'Онцлогууд:',
        style: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 12),
      _FeatureItem(
        icon: Icons.book_online_rounded,
        text: 'Онлайн болон offline унших',
        colorScheme: colorScheme,
      ),
      _FeatureItem(
        icon: Icons.bookmark_rounded,
        text: 'Дуртай номуудаа хадгалах',
        colorScheme: colorScheme,
      ),
      _FeatureItem(
        icon: Icons.notifications_active_rounded,
        text: 'Шинэ номын мэдэгдэл авах',
        colorScheme: colorScheme,
      ),
      _FeatureItem(
        icon: Icons.star_rounded,
        text: 'Номуудыг үнэлэх, сэтгэгдэл бичих',
        colorScheme: colorScheme,
      ),
      const SizedBox(height: 24),

      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Холбоо барих',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'support@readpact.mn',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final ColorScheme colorScheme;

  const _FeatureItem({
    required this.icon,
    required this.text,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}