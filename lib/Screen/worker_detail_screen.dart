import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkerDetailScreen extends StatefulWidget {
  final Map<String, dynamic> worker;

  WorkerDetailScreen({required this.worker});

  @override
  _WorkerDetailScreenState createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> comments = [];
  int? userId;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _fetchComments();
    _checkIfFavorite();
  }

  // ฟังก์ชันตรวจสอบว่าเป็นรายการโปรดแล้วหรือยัง
  Future<void> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final techId = widget.worker['tech_id'];

    if (userId != null && techId != null) {
      // ลองดึงสถานะรายการโปรดจาก SharedPreferences โดยใช้ userId และ techId ร่วมกัน
      final isFavorite = prefs.getBool('isFavorite_${userId}_${techId}');
      if (isFavorite != null) {
        setState(() {
          _isFavorite = isFavorite;
        });
      } else {
        // ถ้าไม่มีใน SharedPreferences, ไปดึงจาก API
        final url = Uri.parse('http://10.0.0.89:3000/favorites?user_id=$userId&tech_id=$techId');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          setState(() {
            _isFavorite = jsonDecode(response.body)['is_favorite'];
          });
          // บันทึกสถานะลง SharedPreferences
          await prefs.setBool('isFavorite_${userId}_${techId}', _isFavorite);
        }
      }
    }
  }

  // ฟังก์ชันเพิ่มหรือลบช่างจากรายการโปรด
  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final techId = widget.worker['tech_id'];

    if (userId == null || techId == null) {
      print('Error: User not logged in or Tech ID is missing');
      return;
    }

    final url = Uri.parse('http://10.0.0.89:3000/toggle_favorite');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "tech_id": techId,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _isFavorite = !_isFavorite;  // สลับสถานะโปรด
      });
      // บันทึกสถานะรายการโปรดลงใน SharedPreferences โดยใช้ userId และ techId ร่วมกัน
      await prefs.setBool('isFavorite_${userId}_${techId}', _isFavorite);
    } else {
      print('Failed to toggle favorite: ${response.statusCode}');
    }
  }


  // ฟังก์ชันสำหรับดึงข้อมูลผู้ใช้
  Future<void> _fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
  }

  // ฟังก์ชันสำหรับดึงข้อมูลคอมเมนต์
  Future<void> _fetchComments() async {
    final techId = widget.worker['tech_id'];
    if (techId == null) {
      print('Error: Tech ID is missing');
      return;
    }

    final url = Uri.parse('http://10.0.0.89:3000/reviews/$techId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          comments = data.map((comment) => {
            "username": comment['username'],
            "comment": comment['comment'],
            "created_at": comment['created_at']
          }).toList();
        });
      } else {
        print('Failed to load comments');
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  // ฟังก์ชันสำหรับการเพิ่มคอมเมนต์
  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      print('Error: User not logged in');
      return;
    }

    final techId = widget.worker['tech_id'];
    if (techId == null) {
      print('Error: Tech ID is missing');
      return;
    }

    final url = Uri.parse('http://10.0.0.89:3000/reviews');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "tech_id": techId,
        "comment": _commentController.text,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        comments.add({
          "username": "ผู้ใช้", // Example username
          "comment": _commentController.text,
          "created_at": DateTime.now().toIso8601String()
        });
        _commentController.clear();
      });
    } else {
      print('Failed to submit comment: ${response.statusCode}');
    }
  }

  // ฟังก์ชันสำหรับการแปลงเวลา
  String _formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  @override
  Widget build(BuildContext context) {
    final worker = widget.worker;

    return Scaffold(
      appBar: AppBar(
        title: Text("รายละเอียดช่าง"),
        backgroundColor: Color(0xFFFFC107),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipOval(
                child: _buildProfileImage(worker['profile_img']),
              ),
            ),
            SizedBox(height: 16),
            Text("ชื่อ: ${worker['tech_name']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("อายุ: ${worker['age']} ปี"),
            Text("อาชีพ: ${worker['type_tech']}"),
            Text("เบอร์โทร: ${worker['phone_num']}"),
            Text("ที่อยู่: ${worker['address']}"),
            Divider(),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: _toggleFavorite,  // เปลี่ยนให้กดแล้วสลับสถานะ
                ),
                Text(_isFavorite ? 'เพิ่มไปยังรายการโปรดแล้ว' : 'เพิ่มไปยังรายการโปรด')
              ],
            ),
            Divider(),
            Text("คอมเมนต์", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return ListTile(
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
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(labelText: "เพิ่มคอมเมนต์"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับแสดงภาพโปรไฟล์
  Widget _buildProfileImage(String? profileImgUrl) {
    if (profileImgUrl != null && profileImgUrl.isNotEmpty) {
      final url = profileImgUrl.startsWith('http') || profileImgUrl.startsWith('uploads')
          ? (profileImgUrl.startsWith('http') ? profileImgUrl : 'http://10.0.0.89:3000/$profileImgUrl')
          : null;

      if (url != null) {
        return Image.network(
          url,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset("assets/images/default.png", width: 100, height: 100, fit: BoxFit.cover);
          },
        );
      }
    }
    return Image.asset("assets/images/default.png", width: 100, height: 100, fit: BoxFit.cover);
  }
}
