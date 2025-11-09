class DonationCardModel {
  final int id;
  final String kind; // 'info', 'progress', 'cta'
  final String? title;
  final String? body;
  final String? icon;
  final double? objectif;
  final double? actuel;
  final String? buttonLabel;
  final String? buttonUrl;
  final int sortOrder;

  DonationCardModel({
    required this.id,
    required this.kind,
    this.title,
    this.body,
    this.icon,
    this.objectif,
    this.actuel,
    this.buttonLabel,
    this.buttonUrl,
    required this.sortOrder,
  });

  factory DonationCardModel.fromMap(Map<String, dynamic> map) {
    double? toD(n) => n == null ? null : (n as num).toDouble();
    return DonationCardModel(
      id: map['id'] as int,
      kind: map['kind'] as String,
      title: map['title'] as String?,
      body: map['body'] as String?,
      icon: map['icon'] as String?,
      objectif: toD(map['objectif']),
      actuel: toD(map['actuel']),
      buttonLabel: map['button_label'] as String?,
      buttonUrl: map['button_url'] as String?,
      sortOrder: (map['sort_order'] ?? 0) as int,
    );
  }
}

