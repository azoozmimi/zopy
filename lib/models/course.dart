class Course {
  final int id;
  final int cohortId;
  final String nameAr;
  final String nameEn;
  final String code;
  final String doctorName;

  Course({
    required this.id,
    required this.cohortId,
    required this.nameAr,
    required this.nameEn,
    required this.code,
    required this.doctorName,
  });

  String localizedName(String langCode) => langCode == 'ar' ? nameAr : nameEn;

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      cohortId: json['cohortId'] as int? ?? 0,
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      code: json['code'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
    );
  }
}
