import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'worker_detail_screen.dart'; // นำเข้า WorkerDetailScreen

class FavoriteWorkersScreen extends StatefulWidget {
  @override
  _FavoriteWorkersScreenState createState() => _FavoriteWorkersScreenState();
}

class _FavoriteWorkersScreenState extends State<FavoriteWorkersScreen> {
  List<Map<String, dynamic>> favoriteWorkers = [];

  @override
  void initState() {
    super.initState();
    _fetchFavoriteWorkers();
  }

  Future<void> _fetchFavoriteWorkers() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      print('Error: User not logged in');
      return;
    }

    final url = Uri.parse('http://10.0.0.89:3000/favorites/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        favoriteWorkers = data.map((worker) {
          return {
            'tech_id': worker['tech_id'],
            'tech_name': worker['tech_name'],
            'profile_img': worker['profile_img'],
            'age': worker['age'],
            'type_tech': worker['type_tech'],
            'phone_num': worker['phone_num'],
            'address': worker['address'],
            'is_favorite': worker['is_favorite'] ?? false,
          };
        }).toList();
      });
    } else if (response.statusCode == 404) {
      setState(() {
        favoriteWorkers = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('คุณยังไม่มีช่างคนโปรด'),
        backgroundColor: Colors.red,
      ));
    } else {
      print('Failed to load favorite workers, StatusCode: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ช่างคนโปรดของคุณ"),
        backgroundColor: Color(0xFFFFC107),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: favoriteWorkers.length,
          itemBuilder: (context, index) {
            final worker = favoriteWorkers[index];
            return Card(
              child: ListTile(
                leading: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkerDetailScreen(worker: worker),
                      ),
                    );
                  },
                  child: ClipOval(
                    child: _buildProfileImage(worker['profile_img']),
                  ),
                ),
                title: Text(worker['tech_name']),
                onTap: () {  // เพิ่มการกดที่ ListTile ทั้งหมด
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkerDetailScreen(worker: worker),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileImage(String? profileImgUrl) {
    if (profileImgUrl != null && profileImgUrl.isNotEmpty) {
      final url = profileImgUrl.startsWith('http') || profileImgUrl.startsWith('uploads')
          ? (profileImgUrl.startsWith('http') ? profileImgUrl : 'http://10.0.0.89:3000/$profileImgUrl')
          : null;

      if (url != null) {
        return Image.network(
          url,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset("assets/images/default.png", width: 50, height: 50, fit: BoxFit.cover);
          },
        );
      }
    }
    return Image.asset("assets/images/default.png", width: 50, height: 50, fit: BoxFit.cover);
  }
}
