import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


  bool _isValidEmail(String email) {
    String pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }




  Future<void> _signUp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // ตรวจสอบชื่อผู้ใช้
    if (username.isEmpty || username.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('กรุณากรอกชื่อผู้ใช้ที่ยาวอย่างน้อย 3 ตัวอักษร'),
      ));
      return;
    }

    // ตรวจสอบอีเมล
    if (email.isEmpty || !_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('กรุณากรอกอีเมลที่ถูกต้อง'),
      ));
      return;
    }

    // ตรวจสอบรหัสผ่าน
    if (password.isEmpty || password.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('รหัสผ่านต้องมีความยาวอย่างน้อย 4 ตัวอักษร'),
      ));
      return;
    }

    // ตรวจสอบรหัสผ่านยืนยัน
    if (confirmPassword != password) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('รหัสผ่านยืนยันไม่ตรงกัน'),
      ));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.0.89:3000/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup successful!')));
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup failed')));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error connecting to server')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFC107),
      appBar: AppBar(
        title: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFFFC107),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 120,
                backgroundImage: AssetImage('assets/images/logo3.jpg'),
                backgroundColor: Colors.transparent,
              ),
              SizedBox(height: 20),
              Text(
                "สมัครสมาชิก",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),

              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'กรุณากรอกชื่อ',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                  fillColor: Color(0xFFFDEAB2),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'กรุณากรอก Email',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: Icon(Icons.email),
                  filled: true,
                  fillColor: Color(0xFFFDEAB2),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'กรุณากรอกรหัสผ่าน',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: Icon(Icons.lock),
                  filled: true,
                  fillColor: Color(0xFFFDEAB2),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'ยืนรหัสผ่าน',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: Icon(Icons.lock),
                  filled: true,
                  fillColor: Color(0xFFFDEAB2),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF000000),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  'สมัคร',
                  style: TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
                  'มีบัญชีแล้วกด ที่นี่',
                  style: TextStyle(color: Color(0xFF000000)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
