import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color themeColor = const Color(0xFFFFC107);

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _updatePassword() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userIdInt = prefs.getInt('user_id');
    final String? userId = userIdInt?.toString();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ไม่พบข้อมูลผู้ใช้'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final String newPassword = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('กรุณากรอกรหัสผ่านให้ครบ'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('รหัสผ่านไม่ตรงกัน กรุณาลองใหม่'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    Map<String, dynamic> requestData = {
      'user_id': userId,
      'newPassword': newPassword,
    };

    print("Request Data: $requestData");

    String apiUrl = 'http://10.0.0.89:3000/update-password';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('อัปเดตรหัสผ่านสำเร็จ!'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('เกิดข้อผิดพลาดในการอัปเดตรหัสผ่าน: ${response.statusCode} - ${response.body}'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _logout() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: themeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // เพิ่มระยะห่างจากขอบด้านบน
            SizedBox(height: 20), // ระยะห่างระหว่างขอบด้านบนและปุ่ม

            ElevatedButton(
              onPressed: _showPasswordDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('แก้ไขรหัสผ่าน'),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text('Logout', style: TextStyle(fontSize: 16)),
              onTap: _logout,
              tileColor: Colors.grey[200],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('แก้ไขรหัสผ่าน'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'รหัสผ่านใหม่'),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'ยืนยันรหัสผ่านใหม่'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: _updatePassword,
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }
}


