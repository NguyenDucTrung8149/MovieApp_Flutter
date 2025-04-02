class User {
  final int id;
  final String userName;
  final String? imageUrl;
  final String email;
  final String name;
  final String phone;
  final int age;
  final bool locked;
  final bool oauth;
  final String? premiumDuration;

  User({
    required this.id,
    required this.userName,
    this.imageUrl,
    required this.email,
    required this.name,
    required this.phone,
    required this.age,
    required this.locked,
    required this.oauth,
    this.premiumDuration,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      userName: json['userName'],
      imageUrl: json['imageUrl'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      age: json['tuoi'],
      locked: json['locked'],
      oauth: json['oauth'],
      premiumDuration: json['premiumDuration'],
    );
  }
}
