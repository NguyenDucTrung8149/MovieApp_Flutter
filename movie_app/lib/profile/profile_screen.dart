import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:movie_app/profile/widgets/profile_item.dart';
import 'package:movie_app/profile/widgets/user_avatar.dart';
import 'package:movie_app/theme/app_theme.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme_notifier.dart';

class ProfileScreen extends StatefulWidget {
  final Function onLogout;
  const ProfileScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userInfo;
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Consumer(
      builder: (context, ThemeNotifier themeNotifier, child) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(
            'Profile',
            style: theme.textTheme.headlineSmall!.copyWith(
              color: AppDynamicColorBuilder.getGrey900AndWhite(context),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                _showLogoutConfirmationDialog(context);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(
                    width: double.infinity,
                  ),
                  UserAvatar(
                    Avatar: _userInfo?['imageUrl']?.toString() ?? '',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_userInfo?['name']}',
                    style: theme.textTheme.headlineSmall!.copyWith(
                      color: AppDynamicColorBuilder.getGrey900AndWhite(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_userInfo?['email']}',
                    style: theme.textTheme.bodyMedium!.copyWith(
                        color:
                            AppDynamicColorBuilder.getGrey900AndWhite(context),
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (context, index) => ProfileOptionItem(
                        index: index,
                        themeNotifier: themeNotifier,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Bạn có muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onLogout();
              Navigator.of(context).pop();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
