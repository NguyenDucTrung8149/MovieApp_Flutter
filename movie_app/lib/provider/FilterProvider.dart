import 'package:flutter/material.dart';
import 'package:movie_app/Api/ApiService.dart';
import 'package:movie_app/model/Country.dart';
import 'package:movie_app/model/genre.dart';

class FilterProvider extends ChangeNotifier {
  List<Genre> _genres = [];
  List<Country> _countries = [];
  String? _selectedGenreId;
  String? _selectedCountryId;

  // Getter để lấy danh sách thể loại và quốc gia
  List<Genre> get genreIdOptions => _genres;
  List<Country> get countryIdOptions => _countries;

  String? get genreId => _selectedGenreId;
  String? get countryId => _selectedCountryId;

  void setGenre(String? genreId) {
    _selectedGenreId = genreId;
    notifyListeners();
  }

  void setCountry(String? countryId) {
    _selectedCountryId = countryId;
    notifyListeners();
  }

  void applyFilters(String? genreId, String? countryId) {
    _selectedGenreId = genreId;
    _selectedCountryId = countryId;
    notifyListeners();
  }

  // Hàm load danh sách thể loại
  Future<void> _loadGenres() async {
    try {
      _genres = await ApiService.fetchGetGenres();
      print('Genres loaded: ${_genres.length}');
      notifyListeners();
    } catch (e) {
      print("Error loading genres: $e");
    }
  }

  // Hàm load danh sách quốc gia
  Future<void> _loadCountries() async {
    try {
      _countries = await ApiService.fetchGetCountries();
      print('Countries loaded: ${_countries.length}');
      notifyListeners();
    } catch (e) {
      print("Error loading countries: $e");
    }
  }

  void resetFilters() {
    _selectedGenreId = null;
    _selectedCountryId = null;
    notifyListeners();
  }

  // Hàm khởi tạo hoặc gọi riêng để load dữ liệu
  Future<void> loadFilters() async {
    await Future.wait([_loadGenres(), _loadCountries()]);
  }
}
