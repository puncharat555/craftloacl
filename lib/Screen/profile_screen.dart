import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? userId;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');
    if (userId != null) {
      await _fetchUserProfile(userId!);
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchUserProfile(int userId) async {
    try {
      final response = await http.get(Uri.parse('http://10.0.0.89:3000/users?user_id=$userId'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic>) {
          setState(() {
            userData = responseData;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('โปรไฟล์ผู้ใช้'),
        backgroundColor: Colors.amber,
      ),
      backgroundColor: Colors.amber.shade100,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData == null
          ? Center(child: Text('ไม่พบข้อมูลผู้ใช้', style: TextStyle(fontSize: 18, color: Colors.black54)))
          : Center(
        child: Padding(
          padding: EdgeInsets.all(70),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // ช่วยให้ทุกอย่างย้ายขึ้น
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.amber.shade600,
                child: userData!['profile_img'] != null && userData!['profile_img'].isNotEmpty
                    ? (userData!['profile_img'].startsWith('http') || userData!['profile_img'].startsWith('uploads'))
                    ? ClipOval(
                  child: Image.network(
                    userData!['profile_img'].startsWith('http')
                        ? userData!['profile_img']
                        : 'http://10.0.0.89:3000/${userData!['profile_img']}',
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                )
                    : ClipOval(
                  child: Image.asset(
                    "assets/images/default.png", // ใช้ภาพเริ่มต้นเมื่อไม่มี URL หรือไม่พบรูปภาพ
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                )
                    : ClipOval(
                  child: Image.asset(
                    "assets/images/default.png", // ใช้ภาพเริ่มต้นเมื่อไม่มีข้อมูลรูปภาพ
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10), // ลดระยะห่างระหว่างรูปและข้อมูล
              Text(
                userData!['tech_name'] ?? 'ไม่พบชื่อ',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              infoText('อาชีพ', userData!['type_tech'] ?? 'ไม่ระบุ'),
              infoText('อายุ', '${userData!['age'] ?? '-'} ปี'),
              infoText('เบอร์โทร', userData!['phone_num'] ?? '-'),
              infoText('ที่อยู่', userData!['address'] ?? '-'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('แก้ไขข้อมูล',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        '$title: $value',
        style: TextStyle(
          fontSize: 18,
          color: Colors.black54,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
