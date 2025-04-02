class Genre {
  final int genreId;
  final String name;
  final String transName;

  Genre({
    required this.genreId,
    required this.name,
    required this.transName,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      genreId: json['genreId'],
      name: json['name'],
      transName: json['transName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'genreId': genreId,
      'name': name,
      'transName': transName,
    };
  }
}