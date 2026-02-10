class CVModel {
  String id;
  String fullName;
  String email;
  String phone;
  String address;
  String summary;
  List<Experience> experiences;
  List<Education> education;
  List<String> skills;

  CVModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.summary,
    required this.experiences,
    required this.education,
    required this.skills,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'summary': summary,
      'experiences': experiences.map((e) => e.toMap()).toList(),
      'education': education.map((e) => e.toMap()).toList(),
      'skills': skills,
    };
  }

  factory CVModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CVModel(
      id: documentId,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      summary: map['summary'] ?? '',
      experiences: (map['experiences'] as List? ?? [])
          .map((e) => Experience.fromMap(e))
          .toList(),
      education: (map['education'] as List? ?? [])
          .map((e) => Education.fromMap(e))
          .toList(),
      skills: List<String>.from(map['skills'] ?? []),
    );
  }
}

class Experience {
  String company;
  String role;
  String duration;

  Experience({required this.company, required this.role, required this.duration});

  Map<String, dynamic> toMap() => {'company': company, 'role': role, 'duration': duration};

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      company: map['company'] ?? '',
      role: map['role'] ?? '',
      duration: map['duration'] ?? '',
    );
  }
}

class Education {
  String institution;
  String degree;
  String year;

  Education({required this.institution, required this.degree, required this.year});

  Map<String, dynamic> toMap() => {'institution': institution, 'degree': degree, 'year': year};

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      institution: map['institution'] ?? '',
      degree: map['degree'] ?? '',
      year: map['year'] ?? '',
    );
  }
}
