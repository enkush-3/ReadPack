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

  Widget buildAppTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Read", style: GoogleFonts.playfairDisplay(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black)),
        SizedBox(width: 4),
        Text("Pact", style: GoogleFonts.playfairDisplay(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF425CAC))),
      ],
    );
  }

  Widget buildRegisterHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text("Нэвтрэх", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFB0B0B0))),
              ),
            ),
            Expanded(child: Text("Бүртгүүлэх", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF425CAC)))),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(child: Container(height: 3, color: Color(0xFFD9D9D9))),
            Expanded(child: Container(height: 3, color: Color(0xFF425CAC))),
          ],
        ),
      ],
    );
  }

  Widget buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("И-мэйл", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF425CAC), fontStyle: FontStyle.italic)),
        SizedBox(height: 8),
        Container(
          height: 50,
          constraints: BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF425CAC), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              hintText: "И-мэйл хаягаа оруулна уу",
              hintStyle: GoogleFonts.inter(fontSize: 16, color: Colors.grey[500]),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Нууц үг", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF425CAC), fontStyle: FontStyle.italic)),
        SizedBox(height: 8),
        Container(
          height: 50,
          constraints: BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF425CAC), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  obscureText: _isPasswordObscured,
                  controller: passwordController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 12, right: 8),
                    hintText: "Нууц үгээ оруулна уу",
                    hintStyle: GoogleFonts.inter(fontSize: 16, color: Colors.grey[500]),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility, color: Color(0xFF425CAC)),
                onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Нууц үг давтах", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF425CAC), fontStyle: FontStyle.italic)),
        SizedBox(height: 8),
        Container(
          height: 50,
          constraints: BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF425CAC), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  obscureText: _isConfirmObscured,
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 12, right: 8),
                    hintText: "Нууц үгээ дахин оруулна уу",
                    hintStyle: GoogleFonts.inter(fontSize: 16, color: Colors.grey[500]),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(_isConfirmObscured ? Icons.visibility_off : Icons.visibility, color: Color(0xFF425CAC)),
                onPressed: () => setState(() => _isConfirmObscured = !_isConfirmObscured),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRegisterButton() {
    return Container(
      width: 380,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          backgroundColor: Color(0xFF425CAC),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () {
          String email = emailController.text;
          String password = passwordController.text;
          String confirmPassword = confirmPasswordController.text;

          if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Бүх талбарыг бөглөнө үү'), backgroundColor: Colors.red),
            );
            return;
          }

          if (password != confirmPassword) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Нууц үг таарахгүй байна'), backgroundColor: Colors.red),
            );
            return;
          }

          print("REGISTER → EMAIL: $email, PASSWORD: $password");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Амжилттай бүртгэгдлээ!'), backgroundColor: Colors.green),
          );
        },
        child: Text("Бүртгүүлэх", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget buildRegisterUI() {
    return Column(
      children: [
        buildRegisterHeader(),
        SizedBox(height: 50),
        buildEmailField(),
        SizedBox(height: 16),
        buildPasswordField(),
        SizedBox(height: 24),
        buildConfirmPasswordField(),
        SizedBox(height: 24),
        buildRegisterButton(),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Бүртгэлтэй бол", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFD9D9D9))),
            SizedBox(width: 4),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text("Нэвтрэх", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF425CAC))),
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(height: 120),
              buildAppTitle(),
              SizedBox(height: 120),
              buildRegisterUI(),
            ],
          ),
        ),
      ),
    );
  }
}