class User {
  final int userId;
  final String username;
  final String techName;
  final int age;
  final String phoneNum;
  final String address;
  final String typeTech;
  final String profileImg;
  final int roleId;

  User({
    required this.userId,
    required this.username,
    required this.techName,
    required this.age,
    required this.phoneNum,
    required this.address,
    required this.typeTech,
    required this.profileImg,
    required this.roleId,
  });

  // ฟังก์ชันสำหรับแปลง JSON เป็น Object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      techName: json['tech_name'],
      age: json['age'],
      phoneNum: json['phone_num'],
      address: json['address'],
      typeTech: json['type_tech'],
      profileImg: json['profile_img'],
      roleId: json['role_id'],
    );
  }
}
