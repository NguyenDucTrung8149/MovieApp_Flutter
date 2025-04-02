import 'package:flutter/material.dart';
import 'package:movie_app/Api/ApiService.dart';
import 'package:movie_app/explore/widgets/search_and_filter.dart';
import 'package:movie_app/global/widgets/movies_grid.dart';
import 'package:movie_app/model/Movie.dart';
import 'package:movie_app/provider/FilterProvider.dart';
import 'package:movie_app/provider/SearchProvider.dart';
import 'package:provider/provider.dart';

class ExploreScreen extends StatefulWidget {
  final Future<List<Movie>> movies;
  const ExploreScreen({Key? key, required this.movies}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<List<Movie>> filteredMovies;
  FilterProvider? filterProvider;
  @override
  void initState() {
    super.initState();
    filteredMovies = widget.movies;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      filterProvider = Provider.of<FilterProvider>(context, listen: false);
      filterProvider?.addListener(_updateFilteredMovies);
    });
  }

  void _updateFilteredMovies() {
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);
    setState(() {
      filteredMovies = ApiService.fetchFilteredMovies(
        filterProvider.genreId,
        filterProvider.countryId,
      );
    });
  }

  @override
  void dispose() {
    filterProvider?.removeListener(_updateFilteredMovies);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SearchAndFilter(),
            FutureBuilder<List<Movie>>(
              future: filteredMovies,
              builder: (context, snapshot) {
                final searchResults =
                    Provider.of<SearchProvider>(context).searchResults;

                if (snapshot.connectionState == ConnectionState.waiting &&
                    searchResults.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('Không tìm thấy kết quả')),
                  );
                } else if ((snapshot.data?.isEmpty ?? true) &&
                    searchResults.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text('Không tìm thấy kết quả')),
                  );
                } else {
                  final movies =
                      searchResults.isNotEmpty ? searchResults : snapshot.data!;
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    sliver: MoviesGrid(movies: movies),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
