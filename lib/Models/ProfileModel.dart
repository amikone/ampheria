class ProfileModel {
  final String id;
  final String username;
  final String fullName;
  final String? gender;
  final String? bio;
  final DateTime? birthDate;
  final List<String> photos;
  final String? location;
  final String? city;

  ProfileModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.gender,
    required this.bio,
    required this.birthDate,
    required this.photos,
    this.location,
    this.city,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'].toString(),
      username: map['username'],
      fullName: map['full_name'],
      gender: map['gender'],
      bio: map['bio'],
      birthDate: map['birth_date'] != null ? DateTime.parse(map['birth_date']) : null,
      photos: map['photos'] != null ? List<String>.from((map['photos'] as List<dynamic>)) : [],
      location: map['location']?.toString(),
      city: map['city']?.toString(),
    );
  }
}