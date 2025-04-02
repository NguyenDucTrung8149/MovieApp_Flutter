import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:movie_app/Api/ApiService.dart';
import 'package:movie_app/global/constants/image_routes.dart';
import 'package:movie_app/global/widgets/MovieDetailScreen.dart';
import 'package:movie_app/global/widgets/project_app_bar.dart';
import 'package:movie_app/model/LoveList.dart';
import 'package:movie_app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyListScreen extends StatefulWidget {
  static final GlobalKey<_MyListScreenState> globalKey = GlobalKey();

  MyListScreen({Key? key}) : super(key: globalKey);

  static _MyListScreenState? of(BuildContext context) {
    return globalKey.currentState;
  }

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  late Future<List<LoveList>> _loveListFuture;

  @override
  void initState() {
    super.initState();
    _loveListFuture = _loadLoveList();
  }

  Future<List<LoveList>> _loadLoveList() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString('userInfo');
    if (userInfoString != null) {
      Map<String, dynamic> userInfo = jsonDecode(userInfoString);
      String username = userInfo['username'];
      return ApiService.fetchLoveList(username);
    } else {
      // Ném lỗi nếu không có thông tin người dùng
      throw Exception("User not logged in");
    }
  }

  void reloadLoveList() {
    setState(() {
      _loveListFuture = _loadLoveList();
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 56),
        child: ProjectAppBar(
          appBarTitle: 'My List',
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<LoveList>>(
          future: _loveListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: theme.textTheme.bodyLarge!.copyWith(color: Colors.red),
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<LoveList> loveList = snapshot.data!;
              return ListView.builder(
                itemCount: loveList.length,
                itemBuilder: (context, index) {
                  LoveList item = loveList[index];
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailScreen(
                                movie: item.movie,
                                genre: item.movie.genres,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                          decoration: BoxDecoration(
                            color: AppDynamicColorBuilder.getGrey100AndDark2(
                                context),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.movie.imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.movie.name,
                                      style:
                                          theme.textTheme.bodyLarge!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.movie.currentEpisodes}/${item.movie.duration} Tập',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppDynamicColorBuilder
                                            .getGrey100AndDark2(context),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${item.movie.rating} /5.0',
                                            style: theme.textTheme.bodySmall!
                                                .copyWith(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete,
                                    color: Colors.red.shade400),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Xác nhận'),
                                      content: Text(
                                          'Bạn có chắc muốn xóa mục này khỏi yêu thích?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context), // Hủy
                                          child: Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(
                                                context); // Đóng dialog
                                            try {
                                              print('${item.id}');
                                              ApiService.deleteLoveListItem(
                                                      listId: item.id)
                                                  .then((value) {
                                                reloadLoveList();
                                              });
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Không thể xóa mục này khỏi yêu thích'),
                                              ));
                                            }
                                          },
                                          child: Text('Xóa',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: double.infinity),
                  Image.asset(
                    theme.brightness == Brightness.dark
                        ? AppImagesRoute.emptyListDark
                        : AppImagesRoute.emptyListLight,
                    height: 220,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(height: 44),
                  Text('Your List is Empty',
                      style: theme.textTheme.headlineMedium!
                          .copyWith(color: theme.primaryColor)),
                  const SizedBox(height: 16),
                  Text(
                    'It seems that you haven\'t added\n any movies to the list',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge!.copyWith(
                        color:
                            AppDynamicColorBuilder.getGrey800AndWhite(context),
                        fontWeight: FontWeight.w500,
                        height: 1.5),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
