class CVModel {
  String id;
  String userId;
  String cvName;
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

  factory CVModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CVModel(
      id: documentId,
      userId: map['userId'] ?? '',
      cvName: map['cvName'] ?? 'Untitled CV',
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
