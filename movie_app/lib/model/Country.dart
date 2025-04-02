class Country {
  final int id;
  final String name;
  final String? nameAnother;

  Country({
    required this.id,
    required this.name,
    this.nameAnother,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      nameAnother: json['nameanother'],
    );
  }
}
