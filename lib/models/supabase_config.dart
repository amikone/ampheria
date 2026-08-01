class SupabaseConfig {
  final String name;
  final String description;
  final String url;
  final String publishableKey;

  SupabaseConfig({
    required this.name,
    required this.description,
    required this.url,
    required this.publishableKey,
  });

  factory SupabaseConfig.fromJson(Map<String, dynamic> json) {
    return SupabaseConfig(
      name: json['name'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      publishableKey: (json['key']) as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'url': url,
      'key': publishableKey,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupabaseConfig &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}
