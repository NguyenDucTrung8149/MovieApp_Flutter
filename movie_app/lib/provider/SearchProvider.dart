import 'dart:async';
import 'package:flutter/material.dart';
import 'package:movie_app/Api/ApiService.dart';
import 'package:movie_app/model/Movie.dart';

class SearchProvider extends ChangeNotifier {
  List<Movie> _searchResults = [];
  bool _isLoading = false;

  List<Movie> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  Timer? _debounce;

  // Thêm các thuộc tính cho bộ lọc
  String? _selectedGenreId;
  String? _selectedRegionId;

  String? get selectedGenreId => _selectedGenreId;
  String? get selectedRegionId => _selectedRegionId;

  void updateGenre(String? genreId) {
    _selectedGenreId = genreId;
    notifyListeners();
  }

  void updateRegion(String? regionId) {
    _selectedRegionId = regionId;
    notifyListeners();
  }

  void searchMovies(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        _searchResults = [];
        notifyListeners();
        return;
      }

      // Xóa bộ lọc khi tìm kiếm
      _selectedGenreId = null;
      _selectedRegionId = null;

      _isLoading = true;
      notifyListeners();

      try {
        final results = await ApiService.searchMovies(query);
        _searchResults = results;
      } catch (e) {
        print("Search failed: $e");
        _searchResults = [];
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void clearSearch() {
    _searchResults = [];
    _selectedGenreId = null;
    _selectedRegionId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
