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
  int? techId; // techId ที่เชื่อมกับผู้ใช้
  Map<String, dynamic>? userData;
  bool isLoading = true;
  List<Map<String, dynamic>> comments = [];

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

      // ตรวจสอบว่า tech_id มีค่าหรือไม่
      if (userData != null && userData!['tech_id'] != null) {
        await _fetchComments(userData!['tech_id']); // ดึงคอมเมนต์ที่ให้กับ tech_id นี้
      } else {
        print("❌ ไม่พบ tech_id ใน userData");
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchUserProfile(int userId) async {
    try {
      final response = await http.get(Uri.parse('http://10.0.0.89:3000/users?user_id=$userId&tech_id=$techId'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        print("✅ User Data Response: $responseData");

        if (responseData is Map<String, dynamic>) {
          setState(() {
            userData = responseData;
            techId = responseData['tech_id']; // ดึง tech_id ของผู้ใช้
            isLoading = false;
          });

          // หากมี tech_id ก็ไปดึงคอมเมนต์ที่ให้กับ tech_id นี้
          if (techId != null) {
            _fetchComments(techId!);
          } else {
            print("❌ ไม่พบ tech_id ใน userData");
          }
        } else {
          print("❌ รูปแบบข้อมูลที่ได้จาก API ไม่ใช่ Map");
          setState(() => isLoading = false);
        }
      } else {
        print("❌ Error ${response.statusCode}: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchComments(int techId) async {
    print('📌 Fetching comments for Tech ID: $techId');
    final url = Uri.parse('http://10.0.0.89:3000/reviews/$techId');

    try {
      final response = await http.get(url);

      // ตรวจสอบสถานะ HTTP
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // ตรวจสอบข้อมูลที่ได้รับ
        print("✅ Comments Response Data: $responseData");

        // ตรวจสอบว่ามีคอมเมนต์หรือไม่
        if (responseData is List) {
          setState(() {
            comments = List<Map<String, dynamic>>.from(responseData);
          });
          print("✅ Comments Loaded: $comments");
        } else {
          print("❌ ข้อมูลที่ได้ไม่เป็นลิสต์ของคอมเมนต์");
        }
      } else {
        print("❌ Error Fetching Comments: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ Error fetching comments: $e');
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
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.amber.shade600,
              child: userData!['profile_img'] != null && userData!['profile_img'].isNotEmpty
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
                  "assets/images/default.png",
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              userData!['tech_name'] ?? 'ไม่พบชื่อ',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amber.shade800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            infoText('อาชีพ', userData!['type_tech'] ?? 'ไม่ระบุ'),
            infoText('อายุ', '${userData!['age'] ?? '-'} ปี'),
            infoText('เบอร์โทร', userData!['phone_num'] ?? '-'),
            infoText('ที่อยู่', userData!['address'] ?? '-'),
            Divider(),
            Text("คอมเมนต์จากผู้ใช้คนอื่นๆ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            comments.isEmpty
                ? Text("ยังไม่มีคอมเมนต์", style: TextStyle(fontSize: 16, color: Colors.black54))
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.comment, color: Colors.amber),
                    title: Text.rich(
                      TextSpan(
                        text: "${comments[index]['username']}",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        children: [
                          TextSpan(
                            text: " : ${comments[index]['comment']}",
                            style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(_formatTimestamp(comments[index]['created_at'])),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget infoText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        '$title: $value',
        style: TextStyle(fontSize: 18, color: Colors.black54),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }
}
