class Episode {
  final int id;
  final String description;
  final String? episodeLink;
  final String? timeupdate;
  final bool state;

  Episode({
    required this.id,
    required this.description,
    this.episodeLink,
    this.timeupdate,
    required this.state,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'],
      description: json['description'],
      episodeLink: json['episodeLink'],
      timeupdate: json['timeupdate'],
      state: json['state'] ?? false,
    );
  }
}