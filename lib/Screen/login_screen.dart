import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:looting/Screen/home_screen.dart';
import 'package:looting/Screen/homeusers_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  int? userId;
  int? roleId;
  int? techId;

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('http://10.0.0.89:3000/login'), // URL ของ API ที่เชื่อมกับ PostgreSQL
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print(data);
          if (data['success']) {
            setState(() {
              userId = data['user_id'];
              roleId = data['role_id'];
              techId = data['tech_id'];
            });

            //เก็บข้อมูลลง SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setInt('user_id', data['user_id'] ?? 0);  // ตั้งค่า user_id ที่ได้รับจากการตอบกลับ
            await prefs.setInt('role_id', data['role_id'] ?? 0);  // ตั้งค่า role_id ที่ได้รับจากการตอบกลับ  // Default to 0 if null
            await prefs.setInt('tech_id', data['tech_id'] ?? 0);
            // ตรวจสอบค่า user_id
            // int? userId = prefs.getInt('user_id');


// ตรวจสอบค่า role_id
//             int? roleId = prefs.getInt('role_id');
//             print('Role ID: $roleId');


            if (roleId == 1 || roleId == 3) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
                    (route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeUserScreen()),
                    (route) => false,
              );
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('เข้าสู่ระบบสำเร็จ!')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง')));
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกชื่อผู้ใช้และรหัสผ่าน')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFFFC107),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // โลโก้
              CircleAvatar(
                radius: 150,
                backgroundImage: AssetImage('assets/images/logo3.jpg'),
                backgroundColor: Colors.transparent,
              ),
              SizedBox(height: 20),
              Text(
                "ลงชื่อเข้าใช้",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),

              // ช่องกรอกชื่อผู้ใช้
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อผู้ใช้',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                  fillColor: Color(0xFFFDEAB2),
                ),
              ),
              SizedBox(height: 20),
              // ช่องกรอกรหัสผ่าน
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
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
              // ปุ่มล็อกอิน
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'ลงชื่อ',
                  style: TextStyle(
                      color: Color(0xFFFDBF07),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 5),

              // ลิงค์ไปหน้าสมัครสมาชิก
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  'ไม่มีบัญชี? กดที่นี่',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//=============================================

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//
//   Future<void> _login() async {
//     String username = _usernameController.text;
//     String password = _passwordController.text;
//
//     if (username.isNotEmpty && password.isNotEmpty) {
//       try {
//         final response = await http.post(
//           Uri.parse('http://10.0.0.89:3000/login'), // URL ของ API ที่เชื่อมกับ PostgreSQL
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'username': username,
//             'password': password,
//           }),
//         );
//
//         if (response.statusCode == 200) {
//           final data = jsonDecode(response.body);
//           if (data['success']) {
//             int roleId = data['role_id'];
//             String loggedInUsername = data['username'];
//             String loggedInEmail = data['email'];
//
//             // ส่งข้อมูลไปยังหน้าถัดไป
//             Navigator.pushReplacementNamed(
//               context,
//               roleId == 1 ? '/home' : '/homeuser',
//               arguments: {
//                 'username': loggedInUsername,
//                 'email': loggedInEmail,
//               },
//             );
//
//             ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('เข้าสู่ระบบสำเร็จ!')));
//           }
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง')));
//         }
//       } catch (e) {
//         print('Error: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้')));
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('กรุณากรอกชื่อผู้ใช้และรหัสผ่าน')),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Color(0xFFFFC107),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(50.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // โลโก้
//               CircleAvatar(
//                 radius: 150,
//                 backgroundImage: AssetImage('assets/images/logo3.jpg'),
//                 backgroundColor: Colors.transparent,
//               ),
//               SizedBox(height: 20),
//               Text(
//                 "ลงชื่อเข้าใช้",
//                 style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 30),
//
//               // ช่องกรอกชื่อผู้ใช้
//               TextField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   labelText: 'ชื่อผู้ใช้',
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide.none,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   prefixIcon: Icon(Icons.person),
//                   filled: true,
//                   fillColor: Color(0xFFFDEAB2),
//                 ),
//               ),
//               SizedBox(height: 20),
//               // ช่องกรอกรหัสผ่าน
//               TextField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'รหัสผ่าน',
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide.none,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   prefixIcon: Icon(Icons.lock),
//                   filled: true,
//                   fillColor: Color(0xFFFDEAB2),
//                 ),
//                 obscureText: true,
//               ),
//               SizedBox(height: 20),
//               // ปุ่มล็อกอิน
//               ElevatedButton(
//                 onPressed: _login,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 child: Text(
//                   'ลงชื่อ',
//                   style: TextStyle(
//                       color: Color(0xFFFDBF07),
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//               SizedBox(height: 5),
//
//               // ลิงค์ไปหน้าสมัครสมาชิก
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/signup');
//                 },
//                 child: Text(
//                   'ไม่มีบัญชี? กดที่นี่',
//                   style: TextStyle(
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }