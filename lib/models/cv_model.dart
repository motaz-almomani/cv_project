import 'package:cloud_firestore/cloud_firestore.dart';

/// PDF export layout: [modern], [classic], or [minimal].
class CVModel {
  String id;
  String userId;
  String cvName;
  /// Layout id for PDF export.
  String pdfTemplate;
  int createdAtMs;
  int updatedAtMs;
  String fullName;
  String jobTitle;
  String email;
  String phone;
  String address;
  String summary;
  String linkedin;
  String github;
  List<Experience> experiences;
  List<Education> education;
  List<String> courses;
  List<String> skills;
  List<Project> projects;
  List<Certificate> certificates;

  CVModel({
    required this.id,
    required this.userId,
    required this.cvName,
    this.pdfTemplate = 'modern',
    this.createdAtMs = 0,
    this.updatedAtMs = 0,
    required this.fullName,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.address,
    required this.summary,
    this.linkedin = '',
    this.github = '',
    required this.experiences,
    required this.education,
    required this.courses,
    required this.skills,
    required this.projects,
    required this.certificates,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cvName': cvName,
      'pdfTemplate': pdfTemplate,
      'fullName': fullName,
      'jobTitle': jobTitle,
      'email': email,
      'phone': phone,
      'address': address,
      'summary': summary,
      'linkedin': linkedin,
      'github': github,
      'experiences': experiences.map((e) => e.toMap()).toList(),
      'education': education.map((e) => e.toMap()).toList(),
      'courses': courses,
      'skills': skills,
      'projects': projects.map((p) => p.toMap()).toList(),
      'certificates': certificates.map((c) => c.toMap()).toList(),
    };
  }

  static int _timestampToMs(dynamic v) {
    if (v == null) return 0;
    if (v is Timestamp) return v.millisecondsSinceEpoch;
    if (v is int) return v;
    return 0;
  }

  factory CVModel.fromMap(Map<String, dynamic> map, String documentId) {
    final template = map['pdfTemplate'] as String? ?? 'modern';
    final safeTemplate = ['modern', 'classic', 'minimal'].contains(template) ? template : 'modern';
    return CVModel(
      id: documentId,
      userId: map['userId'] ?? '',
      cvName: map['cvName'] ?? 'Untitled CV',
      pdfTemplate: safeTemplate,
      createdAtMs: _timestampToMs(map['createdAt']),
      updatedAtMs: _timestampToMs(map['updatedAt']),
      fullName: map['fullName'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      summary: map['summary'] ?? '',
      linkedin: map['linkedin'] ?? '',
      github: map['github'] ?? '',
      experiences: (map['experiences'] as List? ?? [])
          .map((e) => Experience.fromMap(e))
          .toList(),
      education: (map['education'] as List? ?? [])
          .map((e) => Education.fromMap(e))
          .toList(),
      courses: List<String>.from(map['courses'] ?? []),
      skills: List<String>.from(map['skills'] ?? []),
      projects: (map['projects'] as List? ?? [])
          .map((p) => Project.fromMap(p))
          .toList(),
      certificates: (map['certificates'] as List? ?? [])
          .map((c) => Certificate.fromMap(c))
          .toList(),
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

class Project {
  String name;
  String description;
  String link;

  Project({required this.name, required this.description, this.link = ''});

  Map<String, dynamic> toMap() => {'name': name, 'description': description, 'link': link};

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      link: map['link'] ?? '',
    );
  }
}

class Certificate {
  String name;
  String organization;
  String type; // 'University', 'Academic', 'Course'

  Certificate({required this.name, required this.organization, required this.type});

  Map<String, dynamic> toMap() => {'name': name, 'organization': organization, 'type': type};

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      name: map['name'] ?? '',
      organization: map['organization'] ?? '',
      type: map['type'] ?? 'Course',
    );
  }
}
