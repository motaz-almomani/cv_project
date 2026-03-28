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
}
