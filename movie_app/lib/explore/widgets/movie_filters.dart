import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_app/Api/ApiService.dart';
import 'package:movie_app/provider/SearchProvider.dart';
import 'package:provider/provider.dart';

class MovieFilters extends StatefulWidget {
  final String filterType; // 'regions' hoặc 'genres'
  final Function(String?, String?) onFiltersApplied;

  const MovieFilters({
    Key? key,
    required this.filterType,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  State<MovieFilters> createState() => _MovieFiltersState();
}

class _MovieFiltersState extends State<MovieFilters> {
  List<Map<String, String>> filters = []; // Lưu trữ cả id và name
  String? selectedFilterId;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    try {
      List<Map<String, String>> fetchedFilters = [];
      if (widget.filterType == 'regions') {
        final countries = await ApiService.fetchGetCountries();
        fetchedFilters = countries.map((country) {
          return {'id': country.id.toString(), 'name': country.name};
        }).toList();
      } else if (widget.filterType == 'genres') {
        final genresList = await ApiService.fetchGetGenres();
        fetchedFilters = genresList.map((genre) {
          return {'id': genre.genreId.toString(), 'name': genre.name};
        }).toList();
      }

      setState(() {
        filters = fetchedFilters;
      });
    } catch (error) {
      print("Error loading filters: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterList(
          items: filters.map((filter) => filter['name']!).toList(),
          selectedItemId: selectedFilterId,
          onItemSelected: (id) {
            setState(() {
              selectedFilterId = id;
            });

            // Gọi callback với id và name
            final selectedFilter = filters.firstWhere(
              (filter) => filter['name'] == id,
              orElse: () => {'id': '', 'name': ''},
            );
            widget.onFiltersApplied(selectedFilter['id'], selectedFilter['name']);

            // Cập nhật SearchProvider
            if (widget.filterType == 'regions') {
              Provider.of<SearchProvider>(context, listen: false)
                  .updateRegion(selectedFilter['id']);
            } else if (widget.filterType == 'genres') {
              Provider.of<SearchProvider>(context, listen: false)
                  .updateGenre(selectedFilter['id']);
            }
          },
        ),
      ],
    );
  }

  Widget _buildFilterList({
    required List<String> items,
    required String? selectedItemId,
    required Function(String) onItemSelected,
  }) {
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            onItemSelected(items[index]);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            margin: EdgeInsets.only(
              right: index == items.length - 1 ? 24 : 0,
              left: index == 0 ? 24 : 12,
            ),
            decoration: BoxDecoration(
              color: selectedItemId == items[index]
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                width: 2,
                color: selectedItemId == items[index]
                    ? Colors.transparent
                    : Theme.of(context).primaryColor,
              ),
            ),
            child: Center(
              child: Text(
                items[index],
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: selectedItemId == items[index]
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
