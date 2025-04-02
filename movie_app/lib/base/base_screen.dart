import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:movie_app/home/widgets/LoginPage.dart';
import 'package:movie_app/my_list/my_list_screen.dart';
import 'package:movie_app/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movie_app/Api/ApiService.dart';
import 'package:movie_app/download/download_screen.dart';
import 'package:movie_app/explore/explore_screen.dart';
import 'package:movie_app/global/constants/image_routes.dart';
import 'package:movie_app/home/home_screen.dart';
import 'package:movie_app/model/Movie.dart';
import 'package:movie_app/theme/app_colors.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedBottomNavIndex = 0;
  bool _isLoggedIn = false;
  late Future<List<Movie>> _movies;
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _movies = ApiService.fetchMovies();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  void _onLoginSuccess(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString(
        'userInfo', jsonEncode(userInfo)); // Lưu thông tin người dùng
    if (mounted) {
      setState(() {
        _isLoggedIn = true;
        _selectedBottomNavIndex = 0; // Quay về trang chính sau khi đăng nhập
      });
    }
  }

  void _onLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _selectedBottomNavIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedBottomNavIndex,
        children: _getLayout(_movies),
      ),
      bottomNavigationBar: _isLoggedIn
          ? _buildBottomNavigationBar()
          : null, // Ẩn thanh điều hướng nếu chưa đăng nhập
    );
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedBottomNavIndex = index;
    });
    if (index == 2 && _isLoggedIn) {
      final myListScreenState = MyListScreen.of(context);
      if (myListScreenState != null) {
        myListScreenState.reloadLoveList();
      }
    }
    if (index == 3 && _isLoggedIn) {
      final downloadScreenState = DownloadScreen.of(context);
      if (downloadScreenState != null) {
        downloadScreenState.reloadDownloads();
      }
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(30), topLeft: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            currentIndex: _selectedBottomNavIndex,
            onTap: (value) {
              _onTabChanged(value);
            },
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.grey500,
            items: [
              BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SvgPicture.asset(AppImagesRoute.iconHome),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SvgPicture.asset(AppImagesRoute.iconHomeSelected),
                  ),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SvgPicture.asset(AppImagesRoute.iconExplore),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SvgPicture.asset(AppImagesRoute.iconExploreSelected),
                  ),
                  label: 'Explore'),
              BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SvgPicture.asset(AppImagesRoute.iconMyList),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SvgPicture.asset(AppImagesRoute.iconMyListSelected),
                  ),
                  label: 'My List'),
              BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SvgPicture.asset(AppImagesRoute.iconDownload),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child:
                        SvgPicture.asset(AppImagesRoute.iconDownloadSelected),
                  ),
                  label: 'Download'),
              BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SvgPicture.asset(AppImagesRoute.iconProfile),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SvgPicture.asset(AppImagesRoute.iconProfileSelected),
                  ),
                  label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getLayout(Future<List<Movie>> _movies) {
    if (_isLoggedIn) {
      return [
        const HomeScreen(),
        ExploreScreen(
          movies: _movies,
        ),
        MyListScreen(),
        DownloadScreen(),
        ProfileScreen(onLogout: _onLogout),
      ];
    } else {
      return [
        LoginPage(onLoginSuccess: _onLoginSuccess), // Trang đăng nhập
      ];
    }
  }
}
