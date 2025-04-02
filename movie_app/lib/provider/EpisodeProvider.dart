import 'package:flutter/material.dart';
import 'package:better_player_enhanced/better_player.dart';

class EpisodeProvider extends ChangeNotifier {
  BetterPlayerController? _betterPlayerController;
  String _currentEpisode = '';
  Map<String, String> _currentResolutions = {};

  String get currentEpisode => _currentEpisode;

  BetterPlayerController? get betterPlayerController => _betterPlayerController;

  void setupEpisode(String episodeUrl) {
    if (episodeUrl.isEmpty) return;

    _currentEpisode = episodeUrl;

    // Generate resolutions and default resolution URL
    _currentResolutions = _generateResolutions(episodeUrl);
    String defaultResolutionUrl =
        _generateDefaultResolutionUrl(episodeUrl, "480p");

    // Setup BetterPlayerController
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: false,
        looping: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSubtitles: true,
          enablePlaybackSpeed: true,
          enableProgressText: false,
          controlBarColor: const Color.fromARGB(0, 0, 0, 0),
          iconsColor: Colors.white,
          enableQualities: true,
        ),
      ),
    );

    _betterPlayerController?.setupDataSource(
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        defaultResolutionUrl,
        resolutions: _currentResolutions,
      ),
    );

    notifyListeners();
  }

  String _generateDefaultResolutionUrl(String baseUrl, String quality) {
    String base = baseUrl.substring(0, baseUrl.lastIndexOf("."));
    String extension = baseUrl.substring(baseUrl.lastIndexOf("."));
    return "$base" + "_$quality$extension";
  }

  Map<String, String> _generateResolutions(String baseUrl) {
    List<String> qualities = ["auto", "1080p", "720p", "480p"];
    String base = baseUrl.substring(0, baseUrl.lastIndexOf("."));
    String extension = baseUrl.substring(baseUrl.lastIndexOf("."));
    return {
      for (var quality in qualities)
        quality: quality == "auto" ? baseUrl : "$base" + "_$quality$extension"
    };
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }
}
