import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmObscured = true;

  // Өнгөний тогтмолууд (LoginPage-тэй ижил)
  final Color primaryColor = const Color(0xFF425CAC);
  final Color bgColor = const Color(0xFFF8F9FA);
  final Color textSecondary = const Color(0xFF6B7280);

  Widget buildAppTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.auto_stories, color: primaryColor, size: 36),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Read",
              style: GoogleFonts.playfairDisplay(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -1,
              ),
            ),
            Text(
              "Pact",
              style: GoogleFonts.playfairDisplay(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildRegisterHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Идэвхгүй таб (Нэвтрэх рүү буцах)
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            "Нэвтрэх",
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textSecondary
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Идэвхтэй таб (Бүртгүүлэх)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            "Бүртгүүлэх",
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor
            ),
          ),
        ),
      ],
    );
  }

  // Дахин ашиглаж болохуйц гоё Input Field функц (LoginPage-тэй ижил)
  Widget buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: primaryColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? isObscured : false,
            keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 15, color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: primaryColor,
                  size: 22,
                ),
                onPressed: onToggleVisibility,
              )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF425CAC), Color(0xFF5A73C9)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          String email = emailController.text.trim();
          String password = passwordController.text;
          String confirmPassword = confirmPasswordController.text;

          // Валидац шалгалт
          if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Бүх талбарыг бөглөнө үү'),
                  ],
                ),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            return;
          }

          if (password != confirmPassword) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Нууц үг таарахгүй байна'),
                  ],
                ),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            return;
          }

          print("REGISTER → EMAIL: $email, PASSWORD: $password");

          // Амжилттай мессеж
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Амжилттай бүртгэгдлээ!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );

          // Бүртгүүлсний дараа Login хуудас руу буцах (Жишээ)
          // Navigator.pop(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Бүртгүүлэх",
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              buildAppTitle(),
              const SizedBox(height: 50),
              buildRegisterHeader(),
              const SizedBox(height: 40),

              // Input талбарууд
              buildInputField(
                label: "И-мэйл хаяг",
                hint: "Жишээ нь: yourname@example.com",
                controller: emailController,
              ),
              const SizedBox(height: 24),
              buildInputField(
                label: "Нууц үг",
                hint: "Нууц үгээ оруулна уу",
                controller: passwordController,
                isPassword: true,
                isObscured: _isPasswordObscured,
                onToggleVisibility: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
              ),
              const SizedBox(height: 24),
              buildInputField(
                label: "Нууц үг давтах",
                hint: "Нууц үгээ дахин оруулна уу",
                controller: confirmPasswordController,
                isPassword: true,
                isObscured: _isConfirmObscured,
                onToggleVisibility: () => setState(() => _isConfirmObscured = !_isConfirmObscured),
              ),

              const SizedBox(height: 32),
              buildRegisterButton(),

              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Бүртгэлтэй бол ",
                    style: GoogleFonts.inter(fontSize: 15, color: textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Нэвтрэх",
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}