import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:looting/Screen/worker_detail_screen.dart';

class HomeUserScreen extends StatefulWidget {
  @override
  _HomeUserScreenState createState() => _HomeUserScreenState();
}


class _HomeUserScreenState extends State<HomeUserScreen> {
  int _selectedTabIndex = 0;

  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> workers = [];
  String? selectedFilter;
  final List<String> filters = ["ช่างไฟ", "ช่างประปา", "ช่างแอร์", "ช่างอิเล็กทรอนิกส์", "ช่างยนต์"];

  @override
  void initState() {
    super.initState();
    _fetchWorkers();  // เรียกใช้งานฟังก์ชันดึงข้อมูล
  }

  Future<void> _fetchWorkers() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.0.89:3000/home'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          workers = data.map((worker) {
            return {
              "tech_id": worker["tech_id"],       // เพิ่ม tech_id
              "tech_name": worker["tech_name"],
              "age": worker["age"],
              "phone_num": worker["phone_num"],
              "address": worker["address"],
              "type_tech": worker["type_tech"],
              "profile_img": worker["profile_img"] ?? "assets/images/default.png",
            };
          }).toList();
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('ไม่สามารถโหลดข้อมูลช่างได้'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      print("Fetch Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ'),
        backgroundColor: Colors.red,
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFC107),
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchBar()
            : Text('Craftlocal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFFFC107),
        elevation: 0,
        actions: [_buildSearchButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilters(),
            SizedBox(height: 16),
            Expanded(child: _buildWorkerGrid()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Color(0xFFFFC107), width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.black),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'ค้นหาช่าง...',
                hintStyle: TextStyle(color: Colors.black),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return IconButton(
      icon: Icon(_isSearching ? Icons.clear : Icons.search, color: Colors.black),
      onPressed: () {
        setState(() {
          _isSearching = !_isSearching;
          if (!_isSearching) _searchController.clear();
        });
      },
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: selectedFilter == filter ? Colors.white : Colors.black,
                ),
              ),
              selected: selectedFilter == filter,
              onSelected: (isSelected) {
                setState(() {
                  selectedFilter = isSelected ? filter : null;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.orangeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
                side: BorderSide(color: Colors.orange, width: 1),
              ),
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorkerGrid() {
    // ถ้าข้อมูลว่างเปล่าให้แสดงข้อความ
    if (workers.isEmpty) {
      return Center(child: Text('ไม่พบข้อมูลช่าง'));
    }

    final filteredWorkers = workers.where((worker) {
      if (selectedFilter != null && worker['type_tech'] != selectedFilter) {
        return false;
      }
      if (_searchController.text.isNotEmpty) {
        return worker['address'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
            worker['type_tech'].toLowerCase().contains(_searchController.text.toLowerCase()) || worker['tech_name'].toLowerCase().contains(_searchController.text.toLowerCase());

      }
      return true;
    }).toList();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
        mainAxisSpacing: 10,
      ),
      itemCount: filteredWorkers.length,
      itemBuilder: (context, index) {
        final worker = filteredWorkers[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkerDetailScreen(worker: worker),
              ),
            );

          },
          child: Card(
            elevation: 6,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: Offset(2, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: ClipOval(
                      child: worker['profile_img'] != null && worker['profile_img'].isNotEmpty
                          ? (worker['profile_img'].startsWith('http') || worker['profile_img'].startsWith('uploads'))
                          ? Image.network(
                        worker['profile_img'].startsWith('http')
                            ? worker['profile_img']
                            : 'http://10.0.0.89:3000/${worker['profile_img']}',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                          : Image.asset(
                        "assets/images/default.png",
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                          : Image.asset(
                        "assets/images/default.png",
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    height: 3,
                    width: double.infinity,
                    color: Colors.amber,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xF8FBFBEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ช่าง: ${worker['tech_name']}", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("อายุ: ${worker['age']} ปี"),
                            Text("อาชีพ: ${worker['type_tech'] ?? 'ไม่มีข้อมูล'}"),
                            Text("เบอร์โทร: ${worker['phone_num']}"),
                            Text("ที่อยู่: ${worker['address'] ?? 'ไม่มีข้อมูล'}"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

  }


  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedTabIndex,
      onTap: (index) {
        if (_selectedTabIndex == index) return;

        setState(() {
          _selectedTabIndex = index;
        });

        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/homeuser');
            break;
          case 1:
            Navigator.pushNamed(context, '/settings');
            break;
          case 2:
            Navigator.pushNamed(context, '/favorite');
            break;
          case 3:
            Navigator.pushNamed(context, '/profileuser');
            break;
        }
      },
      selectedItemColor: Colors.amber,  // สีที่เลือก (ชัดเจน)
      unselectedItemColor: Colors.black,  // สีที่ไม่ได้เลือก (จางลง)
      backgroundColor: Colors.white,  // พื้นหลังของ BottomNavigationBar
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'ตั้งค่า'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'รายการโปรด'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'สมัครช่าง'),
      ],
    );
  }
}

