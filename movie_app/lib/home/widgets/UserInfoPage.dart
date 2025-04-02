import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:movie_app/global/constants/image_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString('userInfo');
    if (mounted) {
      setState(() {
        if (userInfoString != null) {
          _userInfo = jsonDecode(userInfoString);
        }
        _isLoading = false; // Đánh dấu là đã load xong
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Thông Tin Người Dùng')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userInfo == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Thông Tin Người Dùng')),
        body: Center(child: Text('Không tìm thấy thông tin người dùng')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Thông Tin Người Dùng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _userInfo!['imageUrl'] != null &&
                              _userInfo!['imageUrl'].isNotEmpty
                          ? NetworkImage(
                              'http://192.168.0.100:8080${_userInfo!['imageUrl']}')
                          : AssetImage(AppImagesRoute.userProfileImage)
                              as ImageProvider,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userInfo!['name'] ?? 'Không rõ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _userInfo!['email'] ?? 'Không rõ',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Tên đăng nhập'),
                    subtitle: Text(_userInfo!['username'] ?? 'Không rõ'),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Email'),
                    subtitle: Text(_userInfo!['email'] ?? 'Không rõ'),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('Số điện thoại'),
                    subtitle: Text(_userInfo!['phone'] ?? 'Không rõ'),
                  ),
                  ListTile(
                    leading: Icon(Icons.cake),
                    title: Text('Tuổi'),
                    subtitle: Text('${_userInfo!['tuoi'] ?? 'Không rõ'}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
