import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:looting/Screen/homeusers_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfileuserScreen extends StatefulWidget {
  @override
  ProfileuserScreenState createState() => ProfileuserScreenState();
}

class ProfileuserScreenState extends State<ProfileuserScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _techNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  int? userId;
  int? roleId;

  String? _selectedCategory;
  final List<String> _categories = [
    "ช่างไฟ", "ช่างประปา", "ช่างแอร์", "ช่างอิเล็กทรอนิกส์", "ช่างยนต์"
  ];

  DateTime? _selectedDate;

  File? _profileImage;

  final picker = ImagePicker();

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserData().then((_) => _checkTechAlreadyRegistered());
    _checkTechAlreadyRegistered();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');
    roleId = prefs.getInt('role_id');// Default to 0 if null
    // Default to 0 if null

    print('User ID: $userId');
    print('Role ID: $roleId');
  }

  Future<void> _checkTechAlreadyRegistered() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    roleId = prefs.getInt('role_id'); // โหลด role_id จาก SharedPreferences
    userId = prefs.getInt('user_id'); // โหลด user_id จาก SharedPreferences

    final response = await http.get(Uri.parse('http://10.0.0.89:3000/check_user_role?user_id=$userId'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);  // แปลง response เป็น JSON

      print('Response Data: $responseData');  // ตรวจสอบข้อมูลที่ได้รับ

      if (responseData['role_id'] == 2) {  // ตรวจสอบ role_id จาก JSON
        // สามารถสมัครเป็นช่างได้
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('คุณได้ทำการยื่นสมัครการเป็นช่างแล้ว รอการอนุมัติ')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeUserScreen()),
        );
      }
    } else {
      print('เกิดข้อผิดพลาดในการตรวจสอบข้อมูล');
    }
  }


  Future<void> _pickImage() async {
    // ขอ permission ก่อนเลือกภาพ
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery); // เลือกรูปจากแกลเลอรี่
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);  // เก็บไฟล์ที่เลือก
        });
      }
    } else {
      // ถ้าไม่ได้รับ permission แสดงข้อความเตือน
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('กรุณาให้สิทธิ์ในการเข้าถึงรูปภาพ')));
      final pickedFile = await picker.pickImage(source: ImageSource.gallery); // เลือกรูปจากแกลเลอรี่
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);  // เก็บไฟล์ที่เลือก
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null && _selectedDate != null) {
      final age = _calculateAge(_selectedDate!);
      final formattedDate = _formatDate(_selectedDate!);

      var request = http.MultipartRequest('POST', Uri.parse('http://10.0.0.89:3000/techinfo'));
      request.fields['tech_name'] = _techNameController.text.isNotEmpty ? _techNameController.text : 'ไม่ระบุ';
      request.fields['age'] = age.toString();
      request.fields['phone_num'] = _phoneController.text.isNotEmpty ? _phoneController.text : 'ไม่ระบุ';
      request.fields['address'] = _addressController.text.isNotEmpty ? _addressController.text : 'ไม่ระบุ';
      request.fields['type_tech'] = _selectedCategory ?? 'ไม่ระบุ';
      request.fields['birth_date'] = formattedDate;
      request.fields['user_id'] = userId.toString();

      if (_profileImage != null) {
        var file = await http.MultipartFile.fromPath('profile_image', _profileImage!.path,
            contentType: MediaType('image', 'jpeg'));  // ส่งไฟล์รูปโปรไฟล์
        request.files.add(file);
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        await _updateUserRole(); // อัปเดต role_id เป็น 4
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('บันทึกข้อมูลสำเร็จ!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeUserScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล')));
      }
    }
  }

  Future<void> _updateUserRole() async {
    final response = await http.put(
      Uri.parse('http://10.0.0.89:3000/update_role'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "role_id": 4}),
    );

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('role_id', 4); // อัปเดตค่าใน SharedPreferences
      print("Role ID updated to 4");
    } else {
      print("Failed to update role ID");
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แบบฟอร์มสมัครช่าง'),
        backgroundColor: Colors.amber,
      ),
      backgroundColor: Colors.amber.shade100,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            InkWell(
              onTap: _pickImage, // เมื่อคลิกที่ InkWell ให้เรียกฟังก์ชัน _pickImage
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.shade600,
                  borderRadius: BorderRadius.circular(200),
                ),
                child: _profileImage != null
                    ? ClipOval(
                  child: Image.file(
                    _profileImage!,
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 50, color: Colors.white),
                    SizedBox(height: 8),
                    Text('คลิกเพื่อเพิ่มรูปโปรไฟล์', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_techNameController, 'ชื่อจริง-นามสกุล'),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start, // จัดข้อความไปทางซ้าย
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'เลือกวันเกิด'
                              : 'วันเกิดที่เลือก: ${_formatDate(_selectedDate!)}', // แสดงวันที่ในรูปแบบที่กำหนด
                          style: TextStyle(fontSize: 16), // ปรับขนาดตัวอักษรถ้าต้องการ
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.black), // เพิ่มกรอบสีดำ
                      ),
                      minimumSize: Size(double.infinity, 50), // กำหนดความกว้างเต็มแนวนอน
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildTextField(_phoneController, 'เบอร์โทรศัพท์', isNumber: true),
                  _buildTextField(_addressController, 'ที่อยู่ (เช่น หน้าม.พะเยา , บริเวณม.พะเยา)'),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'ประเภทช่าง',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: _selectedCategory,
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) => value == null ? 'กรุณาเลือกประเภทช่าง' : null,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('บันทึกข้อมูล'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) => value!.isEmpty ? 'กรุณากรอก $label' : null,
      ),
    );
  }
}
