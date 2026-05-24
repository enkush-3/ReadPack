import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Register.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordObscured = true;

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

  Widget buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("И-мэйл", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: Color(0xFF425CAC))),
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
        Text("Нууц үг", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: Color(0xFF425CAC))),
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
                  controller: passwordController,
                  obscureText: _isPasswordObscured,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 12, right: 8),
                    hintText: "Нууц үгээ оруулна уу",
                    hintStyle: GoogleFonts.inter(fontSize: 16, color: Colors.grey[500]),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility, color: Color(0xFF425CAC)),
                onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildLoginButton() {
    return Container(
      width: 380,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          backgroundColor: Color(0xFF425CAC),
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () {
          print("Email: ${emailController.text}");
          print("Password: ${passwordController.text}");
        },
        child: Text("Нэвтрэх", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget buildLoginHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: Text("Нэвтрэх", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF425CAC)))),
            Expanded(child: Text("Бүртгүүлэх", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFB0B0B0)))),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(child: Container(height: 3, color: Color(0xFF425CAC))),
            Expanded(child: Container(height: 3, color: Color(0xFFD9D9D9))),
          ],
        ),
      ],
    );
  }

  Widget buildLoginUI() {
    return Column(
      children: [
        buildLoginHeader(),
        SizedBox(height: 50),
        buildEmailField(),
        SizedBox(height: 16),
        buildPasswordField(),
        SizedBox(height: 24),
        buildLoginButton(),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Бүртгэл байхгүй бол", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFD9D9D9))),
            SizedBox(width: 4),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage())),
              child: Text("Бүртгүүлэх", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF425CAC))),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(height: 120),
              buildAppTitle(),
              SizedBox(height: 120),
              buildLoginUI(),
            ],
          ),
        ),
      ),
    );
  }
}