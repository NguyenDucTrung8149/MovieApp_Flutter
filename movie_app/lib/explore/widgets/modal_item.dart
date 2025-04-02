import 'package:flutter/material.dart';
import 'package:movie_app/global/constants/app_static_data.dart';

import 'filter_title.dart';
import 'movie_filters.dart';

class ExploreModalItem extends StatelessWidget {
  final int index;
  final Function(String?) onFilterSelected; // Callback để truyền giá trị ra ngoài

  const ExploreModalItem({
    Key? key,
    required this.index,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Xác định loại dữ liệu (regions hoặc genres) dựa trên index
    bool isRegions = index == 0;

    return Column(
      children: [
        FilterTitle(title: AppStaticData.exploreModalTitles[index]),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: MovieFilters(
            filterType: isRegions ? 'regions' : 'genres',
            onFiltersApplied: (selectedFilterId, _) {
              onFilterSelected(selectedFilterId); // Truyền giá trị ID ra ngoài
            },
          ),
        ),
      ],
    );
  }
}

