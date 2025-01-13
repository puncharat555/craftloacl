import 'package:flutter/material.dart';

class WorkerDetailScreen extends StatelessWidget {
  final String name;
  final String phone;
  final String location;
  final String worker;
  final List<Map<String, dynamic>> reviews;
  final String profileImageUrl;
  final double averageRating;

  WorkerDetailScreen({
    required this.name,
    required this.phone,
    required this.location,
    required this.worker,
    required this.reviews,
    required this.profileImageUrl,
    required this.averageRating,
  });

  List<Widget> _buildRatingStars(int rating) {
    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      stars.add(Icon(
        i < rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 20,
      ));
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    int ratingStars = averageRating.round();

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.amber,
        elevation: 4,
      ),
      backgroundColor: Color(0xFFFFE082),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // แสดงโปรไฟล์ช่าง
              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: profileImageUrl.startsWith('http')
                      ? NetworkImage(profileImageUrl)
                      : AssetImage(profileImageUrl) as ImageProvider,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      offset: Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ชื่อ: $name', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.work, color: Colors.blue, size: 24),
                        SizedBox(width: 10),
                        Expanded(child: Text('อาชีพ: $worker', style: TextStyle(fontSize: 18))),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.green, size: 24),
                        SizedBox(width: 10),
                        Expanded(child: Text('เบอร์โทร: $phone', style: TextStyle(fontSize: 18))),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.purple, size: 24),
                        SizedBox(width: 10),
                        Expanded(child: Text('ที่อยู่: $location', style: TextStyle(fontSize: 18))),
                      ],
                    ),
                    SizedBox(height: 12),

                    //
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        ..._buildRatingStars(ratingStars),
                        SizedBox(width: 4),
                        Text('${averageRating.toStringAsFixed(1)}', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Text('รีวิว:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  final reviewRating = review['rating'];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(review['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(review['comment']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _buildRatingStars(reviewRating),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
