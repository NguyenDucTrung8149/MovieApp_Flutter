import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_app/global/constants/image_routes.dart';
import 'package:movie_app/provider/FilterProvider.dart';
import 'package:movie_app/provider/SearchProvider.dart';

import 'package:movie_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class SearchAndFilter extends StatefulWidget {
  const SearchAndFilter({Key? key}) : super(key: key);

  @override
  State<SearchAndFilter> createState() => _SearchAndFilterState();
}

class _SearchAndFilterState extends State<SearchAndFilter> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  Future<void> _initializeFilters() async {
    await Provider.of<FilterProvider>(context, listen: false).loadFilters();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<FilterProvider>(context, listen: false).loadFilters(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('Error loading filters')),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          sliver: const SliverToBoxAdapter(
            child: Row(
              children: [
                SearchField(),
                SizedBox(width: 12),
                FilterButton(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FilterButton extends StatelessWidget {
  const FilterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const FilterSheet(),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.red.withOpacity(0.1),
        ),
        child: Icon(Icons.filter_list, color: Colors.red),
      ),
    );
  }
}

class FilterSheet extends StatefulWidget {
  const FilterSheet({Key? key}) : super(key: key);

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? selectedGenre;
  String? selectedCountry;

  Future<void> _selectGenre(
      BuildContext context, FilterProvider filterProvider) async {
    String? selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppDynamicColorBuilder.getWhiteAndDark2(context),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: filterProvider.genreIdOptions.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            title: const Text('All Genres'),
                            onTap: () => Navigator.pop(context, null),
                          );
                        }
                        final genre = filterProvider.genreIdOptions[index - 1];
                        return ListTile(
                          title: Text(genre.name),
                          onTap: () =>
                              Navigator.pop(context, genre.genreId.toString()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedGenre = selected;
      });
    }
  }

  Future<void> _selectCountry(
      BuildContext context, FilterProvider filterProvider) async {
    String? selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppDynamicColorBuilder.getWhiteAndDark2(context),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: filterProvider.countryIdOptions.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            title: const Text('All Countries'),
                            onTap: () => Navigator.pop(context, null),
                          );
                        }
                        final country =
                            filterProvider.countryIdOptions[index - 1];
                        return ListTile(
                          title: Text(country.name),
                          onTap: () =>
                              Navigator.pop(context, country.id.toString()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedCountry = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filter Movies',
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(color: Colors.red),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _selectGenre(context, filterProvider),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                selectedGenre != null
                    ? filterProvider.genreIdOptions
                        .firstWhere((genre) =>
                            genre.genreId.toString() == selectedGenre)
                        .name
                    : 'Select Genre',
                style: TextStyle(
                    color: AppDynamicColorBuilder.getGrey900AndWhite(context)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _selectCountry(context, filterProvider),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                selectedCountry != null
                    ? filterProvider.countryIdOptions
                        .firstWhere((country) =>
                            country.id.toString() == selectedCountry)
                        .name
                    : 'Select Country',
                style: TextStyle(
                    color: AppDynamicColorBuilder.getGrey900AndWhite(context)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  filterProvider.resetFilters();
                  setState(() {
                    selectedGenre = null;
                    selectedCountry = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  'Reset',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  filterProvider.applyFilters(selectedGenre, selectedCountry);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 254, 254, 254),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatefulWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final FocusNode searchFocusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    ThemeData theme = Theme.of(context);

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: 56.h,
        decoration: BoxDecoration(
          color: AppDynamicColorBuilder.getGrey100AndDark2(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: searchFocusNode.hasFocus
                ? theme.primaryColor
                : AppDynamicColorBuilder.getGrey100AndDark2(context),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          controller: searchController,
          focusNode: searchFocusNode,
          onChanged: (value) => searchProvider.searchMovies(value),
          style: theme.textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: AppDynamicColorBuilder.getGrey900AndWhite(context),
          ),
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: 'Search',
            hintStyle: theme.textTheme.bodyMedium!.copyWith(
              color: AppDynamicColorBuilder.getGrey600AndGrey400(context),
              fontWeight: FontWeight.w500,
            ),
            icon: SvgPicture.asset(
              AppImagesRoute.iconSearch,
              color: searchFocusNode.hasFocus
                  ? theme.primaryColor
                  : AppDynamicColorBuilder.getGrey600AndGrey400(context),
            ),
          ),
        ),
      ),
    );
  }
}
