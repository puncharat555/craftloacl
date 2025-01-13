import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดผู้ใช้'),
        backgroundColor: Colors.amber,
      ),
      body: Container(
        color: Colors.yellow[100],
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.person, size: 80, color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'นาย สมพงศ์ กองครกอบ',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('อายุ 40 ปี', style: TextStyle(fontSize: 18)),
                    Text('เบอร์โทร: 097-xxx-2xx4', style: TextStyle(fontSize: 18)),
                    Text('อาศัยอยู่ที่: จังหวัดเชียงใหม่', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // ฟังก์ชันแก้ไขข้อมูล
                      },
                      child: Text('แก้ไขข้อมูล'),
                    ),
                  ],
                ),
              ),
              Divider(thickness: 1, color: Colors.grey),
              SizedBox(height: 16),
              Text('รีวิว', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              ReviewItem(name: 'แพท', comment: 'บริการดีเป็นกันเอง', rating: 5),
              ReviewItem(name: 'ครูโอ๋', comment: 'แนะนำ', rating: 4),
              ReviewItem(name: 'สุพจน์', comment: 'คุณภาพดีมาก', rating: 5),
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String name;
  final String comment;
  final int rating;

  ReviewItem({required this.name, required this.comment, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, size: 30, color: Colors.amber),
            SizedBox(width: 8),
            Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 4),
        Text(comment, style: TextStyle(fontSize: 16)),
        Row(
          children: List.generate(
            5,
                (index) => Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 20,
            ),
          ),
        ),
        Divider(thickness: 1, color: Colors.grey[300]),
      ],
    );
  }
}
