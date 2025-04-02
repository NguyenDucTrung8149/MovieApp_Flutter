import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_app/Api/ApiService.dart';
import 'package:movie_app/global/constants/image_routes.dart';
import 'package:movie_app/global/widgets/MovieDetailScreen.dart';
import 'package:movie_app/model/Movie.dart';
import 'package:movie_app/model/genre.dart';
import 'package:movie_app/provider/SearchProvider.dart';
import 'package:movie_app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopHeader extends StatefulWidget {
  const TopHeader({super.key});

  @override
  State<TopHeader> createState() => _TopHeaderState();
}

class _TopHeaderState extends State<TopHeader> {
  bool _isBottomSectionHidden = false;
  late Future<Movie> _topMovieFuture;
  void updateBottomSectionVisibility(bool isHidden) {
    setState(() {
      _isBottomSectionHidden = isHidden;
    });
  }

  @override
  void initState() {
    super.initState();
    _topMovieFuture = ApiService.fetchTopMovie(); // Gọi API một lần
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          _TopImageSection(topMovieFuture: _topMovieFuture),
          _TopIconsSection(
            onSearchActiveChange: (isSearchActive) {
              updateBottomSectionVisibility(isSearchActive);
            },
          ),
          _BottomSection(
            isHidden: _isBottomSectionHidden,
            topMovieFuture: _topMovieFuture,
          ),
        ],
      ),
    );
  }
}

class _TopIconsSection extends StatefulWidget {
  final ValueChanged<bool> onSearchActiveChange;

  const _TopIconsSection({required this.onSearchActiveChange});

  @override
  State<_TopIconsSection> createState() => _TopIconsSectionState();
}

class _TopIconsSectionState extends State<_TopIconsSection> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: _isSearchActive
                      ? _buildSearchField(searchProvider)
                      : SvgPicture.asset(
                          AppImagesRoute.appLogo,
                          key: const ValueKey('logo'),
                        ),
                ),
              ),
              if (!_isSearchActive) const SizedBox(width: 250),
              if (!_isSearchActive)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearchActive = true;
                      widget.onSearchActiveChange(true);
                    });
                  },
                  child: SvgPicture.asset(AppImagesRoute.iconSearch),
                ),
              if (!_isSearchActive) const SizedBox(width: 24),
            ],
          ),
          if (_isSearchActive) _buildSearchResults(searchProvider),
        ],
      ),
    );
  }

  Widget _buildSearchField(SearchProvider searchProvider) {
    return TextField(
      key: const ValueKey('searchField'),
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Nhập thông tin tìm kiếm...",
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        prefixIcon: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            setState(() {
              _isSearchActive = false;
              _searchController.clear();
            });
            searchProvider.clearSearch();
            widget.onSearchActiveChange(false);
          },
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.black),
                onPressed: () {
                  _searchController.clear();
                  searchProvider.clearSearch();
                },
              )
            : null,
      ),
      style: const TextStyle(color: Colors.black),
      onChanged: (value) {
        searchProvider.searchMovies(value);
      },
    );
  }

  Widget _buildSearchResults(SearchProvider searchProvider) {
    if (_searchController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    if (searchProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchProvider.searchResults.isEmpty) {
      return const Center(
        child: Text(
          "Không tìm thấy kết quả.",
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(maxHeight: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchProvider.searchResults.length,
                itemBuilder: (context, index) {
                  final movie = searchProvider.searchResults[index];
                  return ListTile(
                    leading: Image.network(movie.imageUrl),
                    title: Text(
                      movie.name,
                      style: const TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      // Điều hướng đến MovieDetailScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailScreen(
                            movie: movie,
                            genre: movie.genres,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _TopImageSection extends StatelessWidget {
  final Future<Movie> topMovieFuture;

  const _TopImageSection({required this.topMovieFuture});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const designHeight = 926.0;
    const imageHeight = 400.0;

    final heightRatio = screenHeight / designHeight;
    final responsiveImageHeight = heightRatio * imageHeight;

    return FutureBuilder<Movie>(
      future: topMovieFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading image'));
        } else if (snapshot.hasData) {
          return ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: FractionalOffset.bottomLeft,
              end: FractionalOffset.center,
              colors: [
                Color(0xff181A20),
                Colors.white,
              ],
            ).createShader(bounds),
            blendMode: BlendMode.modulate,
            child: Image.network(
              snapshot.data!.imageUrl,
              fit: BoxFit.cover,
              height: responsiveImageHeight,
              width: double.infinity,
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class _BottomSection extends StatelessWidget {
  final bool isHidden;
  final Future<Movie> topMovieFuture;

  const _BottomSection({
    required this.isHidden,
    required this.topMovieFuture,
  });

  @override
  Widget build(BuildContext context) {
    if (isHidden) {
      return const SizedBox.shrink();
    }

    ThemeData theme = Theme.of(context);

    return Positioned(
      bottom: 24,
      left: 24,
      child: FutureBuilder<Movie>(
        future: topMovieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading movie'));
          } else if (snapshot.hasData) {
            final movie = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.name,
                  style: theme.textTheme.headlineMedium!
                      .copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<Genre>>(
                  future: ApiService().fetchGenres(movie.movieId),
                  builder: (context, genreSnapshot) {
                    if (genreSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (genreSnapshot.hasError) {
                      return const Center(child: Text('Error loading genres'));
                    } else if (genreSnapshot.hasData) {
                      final genreNames = genreSnapshot.data!
                          .map((genre) => genre.name)
                          .join(', ');
                      return Text(
                        genreNames,
                        style: theme.textTheme.bodySmall!.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailScreen(
                              movie: snapshot.data!,
                              genre: [],
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(AppImagesRoute.iconPlay),
                          const SizedBox(width: 8),
                          Text(
                            'Play',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              color: AppColors.white, width: 2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final userInfoString = prefs.getString('userInfo');
                        if (userInfoString != null) {
                          Map<String, dynamic> userInfo =
                              jsonDecode(userInfoString);
                          await ApiService.saveToLoveList(
                            username: userInfo['username'],
                            movieId: movie.movieId,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Đã thêm vào danh sách yêu thích!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Bạn cần đăng nhập để sử dụng tính năng này!')),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(AppImagesRoute.iconPlus),
                          const SizedBox(width: 8),
                          Text(
                            'My List',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
