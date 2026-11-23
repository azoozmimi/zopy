class User {
  final int id;
  final String fullName;
  final String email;
  final String username;
  final String? studentId;
  final String role; // Admin, Representative, Student
  final int? cohortId;
  final String? cohortName;
  final int? collegeId;
  final String? collegeName;
  final int? universityId;
  final String? universityName;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.username,
    this.studentId,
    required this.role,
    this.cohortId,
    this.cohortName,
    this.collegeId,
    this.collegeName,
    this.universityId,
    this.universityName,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isRepresentative => role.toLowerCase() == 'representative' || isAdmin;
  bool get isStudent => role.toLowerCase() == 'student';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      studentId: json['studentId'] as String?,
      role: json['role'] as String? ?? 'Student',
      cohortId: json['cohortId'] as int?,
      cohortName: json['cohortName'] as String?,
      collegeId: json['collegeId'] as int?,
      collegeName: json['collegeName'] as String?,
      universityId: json['universityId'] as int?,
      universityName: json['universityName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'username': username,
      'studentId': studentId,
      'role': role,
      'cohortId': cohortId,
      'cohortName': cohortName,
      'collegeId': collegeId,
      'collegeName': collegeName,
      'universityId': universityId,
      'universityName': universityName,
    };
  }
}
