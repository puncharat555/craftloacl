import 'package:flutter/material.dart';
import 'package:looting/Screen/WorkerDetailScreen.dart';
import '';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex =  0;
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> workers = [
    {
      "name": "ช่างโต้",
      "rating": "",
      "phone": "091-XXX-XXXX",
      "type": "ช่างแอร์",
      "location": "พะเยา อ.แม่กา",
      "profileImageUrl": 'assets/images/satoshi.jpg',
      "reviews": [
        {'name': 'ลูกค้า 1', 'comment': 'บริการดีมาก', 'rating': 2},
        {'name': 'ลูกค้า 2', 'comment': 'งานเสร็จไว', 'rating': 1},
      ]
    },
    {
      "name": "ช่างเจม",
      "rating": "",
      "phone": "085-XXX-XXXX",
      "type": "ช่างประปา",
      "location": "เชียงใหม่",
      "profileImageUrl": 'assets/images/profile02.png',
      "reviews": [
        {'name': 'ลูกค้า 3', 'comment': 'ทำงานไม่ครบ', 'rating': 3},
        {'name': 'ลูกค้า 4', 'comment': 'บริการช้า', 'rating': 4},
      ]
    },{
      "name": "ช่างแมว",
      "rating": "",
      "phone": "091-XXX-XXXX",
      "type": "ช่างไฟ",
      "location": "พะเยา อ.แม่กา",
      "profileImageUrl": 'assets/images/satoshi.jpg',
      "reviews": [
        {'name': 'ลูกค้า 1', 'comment': 'บริการดีมาก', 'rating': 2},
        {'name': 'ลูกค้า 2', 'comment': 'งานเสร็จไว', 'rating': 1},
      ]
    },
    {
      "name": "ช่างเก่ง",
      "rating": "",
      "phone": "085-XXX-XXXX",
      "type": "ช่างอิเล็กทรอนิกส์",
      "location": "เชียงใหม่",
      "profileImageUrl": 'assets/images/logo.png',
      "reviews": [
        {'name': 'ลูกค้า 3', 'comment': 'ทำงานไม่ครบ', 'rating': 1},
        {'name': 'ลูกค้า 4', 'comment': 'บริการช้า', 'rating': 1},
      ]
    },
  ];

  final List<String> filters = ["ช่างไฟ", "ช่างประปา", "ช่างแอร์", "ช่างอิเล็กทรอนิกส์"];
  String? selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFC107),
      appBar: AppBar(
        title: _isSearching
            ? Container(
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
        )
            : Text(
          'Craftlocal',
          style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFFFC107),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.clear : Icons.search,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: filters.map((filter) {
                return FilterChip(
                  label: Text(filter),
                  selected: selectedFilter == filter,
                  onSelected: (isSelected) {
                    setState(() {
                      selectedFilter = isSelected ? filter : null;
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.amber,
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 10,
                ),
                itemCount: workers.where((worker) {
                  if (selectedFilter != null) {
                    return worker['type'] == selectedFilter;
                  }
                  if (_searchController.text.isEmpty) {
                    return true;
                  }
                  return worker['name'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
                      worker['type'].toLowerCase().contains(_searchController.text.toLowerCase());
                }).toList().length,
                itemBuilder: (context, index) {
                  final filteredWorkers = workers.where((worker) {
                    if (selectedFilter != null) {
                      return worker['type'] == selectedFilter;
                    }
                    if (_searchController.text.isEmpty) {
                      return true;
                    }
                    return worker['name'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
                        worker['type'].toLowerCase().contains(_searchController.text.toLowerCase());
                  }).toList();

                  final worker = filteredWorkers[index];
                  double averageRating = calculateAverageRating(worker['reviews']);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkerDetailScreen(
                            name: worker['name']!,
                            averageRating: averageRating,
                            phone: worker['phone']!,
                            location: worker['location']!,
                            worker: worker['type'] ?? 'ไม่มีข้อมูล',
                            reviews: worker['reviews'],
                            profileImageUrl: worker['profileImageUrl']!,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      color: Color(0xFFFFF8E1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Color(0xFFFFC107), width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Color(0xFFFFE082), width: 3),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      worker['profileImageUrl'],
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          worker['name']!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.blue,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: buildRatingStars(averageRating),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Color(0xFFFFC107), width: 2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'อาชีพ: ${worker['type'] ?? 'ไม่มีข้อมูล'}',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'คะแนนเฉลี่ย: ${averageRating.toStringAsFixed(1)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'สถานที่: ${worker['location'] ?? 'ไม่มีข้อมูล'}',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'เบอร์โทร: ${worker['phone']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.black),
            label: 'ตั้งค่า',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: 'โปรไฟล์',
          ),
        ],
        backgroundColor: Color(0xFFFFE082),
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/settings');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  double calculateAverageRating(List<dynamic> reviews) {
    if (reviews.isEmpty) return 0.0;
    double totalRating = 0.0;
    for (var review in reviews) {
      totalRating += review['rating'];
    }
    return totalRating / reviews.length;
  }

  List<Widget> buildRatingStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: Colors.amber, size: 20));
      } else if (i < fullStars + 1 && hasHalfStar) {
        stars.add(Icon(Icons.star_half, color: Colors.amber, size: 20));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.amber, size: 20));
      }
    }
    return stars;
  }
}
