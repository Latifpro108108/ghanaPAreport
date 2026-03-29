class User {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String joinedDate;
  final int reportsSubmitted;
  final int helpfulVotes;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.joinedDate,
    required this.reportsSubmitted,
    required this.helpfulVotes,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      joinedDate: json['joinedDate'] ?? '',
      reportsSubmitted: json['reportsSubmitted'] ?? 0,
      helpfulVotes: json['helpfulVotes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'joinedDate': joinedDate,
      'reportsSubmitted': reportsSubmitted,
      'helpfulVotes': helpfulVotes,
    };
  }
}
