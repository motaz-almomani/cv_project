import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cv_project/models/cv_model.dart';

class AIService {
  final String _apiKey = 'AIzaSyD0WThQESoD-OVjAoQIczJ8oaNEd6chnpM'.trim();

  Future<Map<String, dynamic>> analyzeCV(CVModel cv) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey');

    final prompt = """
Analyze this CV and return a STRICT JSON ONLY object with:
- score (0 to 100)
- feedback (Short professional text)
- tips (list of 3 improvement tips)

CV Data:
Name: ${cv.fullName}
Job Title: ${cv.jobTitle}
Skills: ${cv.skills.join(', ')}
Experiences: ${cv.experiences.map((e) => "${e.role} at ${e.company}").join(', ')}
Education: ${cv.education.map((e) => "${e.degree} from ${e.institution}").join(', ')}
Summary: ${cv.summary}

IMPORTANT: RETURN ONLY THE RAW JSON. NO MARKDOWN, NO BACKTICKS, NO EXPLANATION.
{
  "score": number,
  "feedback": "text",
  "tips": ["tip1", "tip2", "tip3"]
}
""";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [{"text": prompt}]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['candidates'][0]['content']['parts'][0]['text'].trim();
        
        if (content.contains('{')) {
          content = content.substring(content.indexOf('{'), content.lastIndexOf('}') + 1);
        }
        
        return jsonDecode(content);
      } else {
        throw Exception("AI Analysis Failed: ${response.statusCode}");
      }
    } catch (e) {
      print('AI Error: $e');
      return {
        "score": 75,
        "feedback": "Good CV, but can be improved with more details.",
        "tips": ["Add more projects", "Improve summary", "Update skills"]
      };
    }
  }

  Future<CVModel?> generateCV({
    required String name,
    required String jobType,
    required String skillLevel,
    required String education,
    required String experiences,
    required String projects,
    required String github,
    required String linkedin,
    required String userId,
  }) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey');

    final prompt = '''
Create a professional CV in JSON format for:
Name: $name
Job Title: $jobType
Skill Level: $skillLevel
Education: $education
Experience: $experiences
Projects: $projects
GitHub: $github
LinkedIn: $linkedin

IMPORTANT: RETURN ONLY THE RAW JSON. NO MARKDOWN, NO BACKTICKS.
{
  "fullName": "$name",
  "jobTitle": "$jobType",
  "summary": "Professional summary based on input",
  "skills": ["skill1", "skill2"],
  "experiences": [{"company": "...", "role": "...", "duration": "..."}],
  "education": [{"institution": "...", "degree": "...", "year": "..."}],
  "courses": ["course1"],
  "projects": [{"name": "...", "description": "...", "link": ""}],
  "certificates": [{"name": "...", "organization": "...", "type": "Course"}],
  "email": "example@email.com",
  "phone": "0000000000",
  "address": "City, Country"
}
''';

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{"parts": [{"text": prompt}]}]
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['candidates'] != null && responseData['candidates'].isNotEmpty) {
          String jsonString = responseData['candidates'][0]['content']['parts'][0]['text'].trim();
          
          if (jsonString.contains('{')) {
            jsonString = jsonString.substring(jsonString.indexOf('{'), jsonString.lastIndexOf('}') + 1);
          }

          final Map<String, dynamic> data = jsonDecode(jsonString);

          return CVModel(
            id: '',
            userId: userId,
            cvName: 'AI Generated - $jobType',
            fullName: data['fullName'] ?? name,
            jobTitle: data['jobTitle'] ?? jobType,
            email: data['email'] ?? 'example@email.com',
            phone: data['phone'] ?? '0000000000',
            address: data['address'] ?? 'City, Country',
            summary: data['summary'] ?? '',
            linkedin: linkedin,
            github: github,
            experiences: (data['experiences'] as List? ?? []).map((e) => Experience.fromMap(e)).toList(),
            education: (data['education'] as List? ?? []).map((e) => Education.fromMap(e)).toList(),
            courses: List<String>.from(data['courses'] ?? []),
            skills: List<String>.from(data['skills'] ?? []),
            projects: (data['projects'] as List? ?? []).map((p) => Project.fromMap(p)).toList(),
            certificates: (data['certificates'] as List? ?? []).map((c) => Certificate.fromMap(c)).toList(),
          );
        }
      }
    } catch (e) {
      print('AI Service Error: $e');
    }
    return null;
  }
}
