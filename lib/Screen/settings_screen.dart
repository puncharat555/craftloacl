import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkModeEnabled = false; // สถานะ Dark Mode

  void _showChangeNameDialog(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('เปลี่ยนชื่อ'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'ชื่อใหม่',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ปิด Dialog
              },
              child: Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                String newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  // TODO: อัปเดตชื่อในฐานข้อมูล
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('เปลี่ยนชื่อสำเร็จ!')),
                  );
                }
                Navigator.pop(context);
              },
              child: Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ตั้งค่า'),
        backgroundColor: Color(0xFFFFC107),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ส่วนหัวโปรไฟล์
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ชื่อผู้ใช้: นาย สมพงศ์ กองครกอบ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('อีเมล: Sompong123@gmail.com'),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('เปลี่ยนชื่อ'),
              onTap: () {
                _showChangeNameDialog(context); // แสดง Dialog เปลี่ยนชื่อ
              },
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('เปลี่ยนอีเมล'),
              onTap: () {
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('เปลี่ยนรหัสผ่าน'),
              onTap: () {
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('ลงชื่อออก'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
