import 'package:flutter/material.dart';
import 'package:movie_app/Api/ApiService.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _email = '';
  String _name = '';
  String _sdt = '';
  int _tuoi = 0;

  // Hàm gọi API Đăng ký thông qua ApiService
  Future<void> register() async {
    try {
      final response = await ApiService.registerUser(
        username: _username,
        password: _password,
        email: _email,
        name: _name,
        phone: _sdt,
        tuoi: _tuoi,
      );

      // Hiển thị kết quả đăng ký
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Đăng ký thành công!')),
      );

      if (response['message'] == 'Đăng ký thành công') {
        Navigator.pop(context); // Quay về trang trước (thường là Đăng nhập)
      }
    } catch (error) {
      // Xử lý lỗi và hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng Ký'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tạo tài khoản mới',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tên đăng nhập',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onSaved: (value) => _username = value ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập tên đăng nhập'
                    : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Họ tên',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                onSaved: (value) => _name = value ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập họ tên'
                    : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                onSaved: (value) => _email = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                onSaved: (value) => _sdt = value ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập số điện thoại'
                    : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tuổi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _tuoi = int.tryParse(value ?? '0') ?? 0,
                validator: (value) {
                  final age = int.tryParse(value ?? '0');
                  if (age == null || age <= 0) {
                    return 'Vui lòng nhập tuổi hợp lệ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                onSaved: (value) => _password = value ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập mật khẩu'
                    : null,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    register();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Đăng Ký',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
