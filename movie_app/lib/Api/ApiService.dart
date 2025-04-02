import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:movie_app/model/Comment.dart';
import 'package:movie_app/model/Country.dart';
import 'package:movie_app/model/LoveList.dart';
import 'package:movie_app/model/Movie.dart';
import 'package:movie_app/model/genre.dart';

class ApiService {
  static const String _baseUrl = "http://192.168.0.19:8080/api";

  static Future<List<Movie>> fetchMovies() async {
    final response = await http.get(Uri.parse("$_baseUrl/movies"));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  static Future<Movie> fetchTopMovie() async {
    final response = await http.get(Uri.parse("$_baseUrl/movietop1"));

    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body);
      return Movie.fromJson(data);
    } else {
      throw Exception('Failed to load top movies');
    }
  }

  static Future<List<Movie>> fetchTopMovies() async {
    final response = await http.get(Uri.parse("$_baseUrl/moviestop10"));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load top movies');
    }
  }

  static Future<Movie?> fetchMovieDetails(int movieId) async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/movies/$movieId"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Movie.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch movie details: $e');
    }
  }

  Future<List<Genre>> fetchGenres(int movieId) async {
    final response = await http.get(Uri.parse("$_baseUrl/genres/$movieId"));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Genre.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load genres');
    }
  }

  static Future<List<Movie>> searchMovies(String query) async {
    try {
      final response =
          await http.get(Uri.parse("$_baseUrl/movies/search?query=$query"));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((movie) => Movie.fromJson(movie)).toList();
      } else {
        throw Exception('Failed to search movies');
      }
    } catch (e) {
      throw Exception('Error during movie search: $e');
    }
  }

  static Future<List<Genre>> fetchGetGenres() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/genres"));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((genre) => Genre.fromJson(genre)).toList();
      } else {
        // Thêm thông báo lỗi từ API
        throw Exception(
            'Failed to load genres: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching genres: $e');
    }
  }

  static Future<List<Country>> fetchGetCountries() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/countries"));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((country) => Country.fromJson(country)).toList();
      } else {
        throw Exception(
            'Failed to load countries: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching countries: $e');
    }
  }

  static Future<List<Movie>> fetchFilteredMovies(
      String? genreId, String? countryId) async {
    final queryParameters = {
      if (genreId != null) 'genreId': genreId,
      if (countryId != null) 'countryId': countryId,
    };

    final response = await http.get(Uri.parse('$_baseUrl/filter')
        .replace(queryParameters: queryParameters));

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((movie) => Movie.fromJson(movie))
          .toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  static Future<void> incrementView(int movieId) async {
    try {
      final response = await http.put(
        Uri.parse("$_baseUrl/incrementView/$movieId"),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to increment view: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error incrementing view: $e');
    }
  }

  static Future<List<Comment>> fetchComments(int episodeId) async {
    final response =
        await http.get(Uri.parse("$_baseUrl/comments?epId=$episodeId"));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((comment) => Comment.fromJson(comment)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  static Future<void> postComment({
    required String username,
    required int episodeId,
    required String content,
    required int rating,
    required int movieId,
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/comments"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": username,
        "episodeId": episodeId,
        "content": content,
        "rating": rating,
        "movieId": movieId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to post comment');
    }
  }

  static Future<void> deleteComment({
    required int commentId,
    required int movieId,
  }) async {
    final url = Uri.parse("$_baseUrl/comments/delete");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "commentId": commentId,
          "movieId": movieId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete comment: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting comment: $e');
    }
  }

  //Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); //Token
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String password,
    required String email,
    required String name,
    required String phone,
    required int tuoi,
  }) async {
    final url = Uri.parse('$_baseUrl/register');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'username': username,
      'password': password,
      'email': email,
      'name': name,
      'phone': phone,
      'tuoi': tuoi,
    });

    final response = await http.post(url, headers: headers, body: body);
    return json.decode(response.body);
  }

  //luu yeu thich
  static Future<void> saveToLoveList({
    required String username,
    required int movieId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/luuyeuthich"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "username": username,
          "movieId": movieId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save movie to love list: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saving movie to love list: $e');
    }
  }

  static Future<List<LoveList>> fetchLoveList(String username) async {
    try {
      final response =
          await http.get(Uri.parse("$_baseUrl/lovelists?username=$username"));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((movie) => LoveList.fromJson(movie)).toList();
      } else {
        throw Exception('Failed to fetch love list');
      }
    } catch (e) {
      throw Exception('Error API fetching love list: $e');
    }
  }

  static Future<List<LoveList>> fetchLoveListByMovie(
      {required String username, required int movieId}) async {
    try {
      final response = await http.get(Uri.parse(
          "$_baseUrl/lovelistByMovieId?username=$username&movieId=$movieId"));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((movie) => LoveList.fromJson(movie)).toList();
      } else {
        throw Exception('Failed to fetch love list');
      }
    } catch (e) {
      throw Exception('Failed API love list: $e');
    }
  }

  static Future<void> deleteLoveListItem({required int listId}) async {
    try {
      final response = await http.delete(
        Uri.parse("$_baseUrl/lovelist/delete?listId=$listId"),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete item from love list: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting item from love list: $e');
    }
  }

  static Future<void> addComment({
    required String username,
    required int episodeId,
    required String content,
    required int rating,
    required int movieId,
  }) async {
    final url = Uri.parse("$_baseUrl/comments");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "username": username,
          "episodeId": episodeId,
          "content": content,
          "rating": rating.toString(),
          "movieId": movieId.toString(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to add comment: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding comment: $e');
    }
  }
}
