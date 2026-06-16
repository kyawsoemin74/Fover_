class StatisticsItem {
  const StatisticsItem({
    required this.dataName,
    required this.label,
    required this.homeValue,
    required this.awayValue,
  });

  final String dataName;
  final String label;
  final dynamic homeValue;
  final dynamic awayValue;

  factory StatisticsItem.fromJson(Map<String, dynamic> json) {
    final dataName = (json['data_name'] ?? json['name'] ?? '').toString();
    final label = (json['label'] ?? '').toString();
    final home = json['home_value'] ?? json['home'] ?? json['homeValue'];
    final away = json['away_value'] ?? json['away'] ?? json['awayValue'];
    return StatisticsItem(
      dataName: dataName,
      label: label,
      homeValue: home,
      awayValue: away,
    );
  }
}
