class PainModel {
  final int id;
  final String name;
  final String tip;
  int intensity;
  String onset;

  PainModel({
    required this.id,
    required this.name,
    required this.tip,
    this.intensity = 1,
    this.onset = 'hoje',
  });
}
