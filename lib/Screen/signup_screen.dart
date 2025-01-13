import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _signUp() {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
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
        padding: const EdgeInsets.fromLTRB(20,0,20,20),
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
              controller: _nameController,
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
            // ช่องกรอกอีเมล
            TextField(
              controller: _emailController,
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

            // ช่องกรอกรหัสผ่าน
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

            // ช่องกรอกรหัสผ่านยืนยัน
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

            // ปุ่มสมัคร
            ElevatedButton(
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF000000),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                'สมัคร',
                style: TextStyle(
                    color: Color(0xFFFFC107),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 5),

            // ลิงค์สำหรับหน้าล็อกอิน
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
    );
  }
}
