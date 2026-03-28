import 'package:cv_project/models/cv_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CVModel uses modern PDF template by default', () {
    final cv = CVModel(
      id: '1',
      userId: 'u',
      cvName: 'Test',
      fullName: 'Jane Doe',
      jobTitle: 'Developer',
      email: 'jane@example.com',
      phone: '',
      address: '',
      summary: '',
      experiences: [],
      education: [],
      courses: [],
      skills: [],
      projects: [],
      certificates: [],
    );
    expect(cv.pdfTemplate, 'modern');
  });
}
