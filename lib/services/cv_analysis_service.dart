import 'package:cv_project/models/cv_model.dart';

class CVAnalysisService {
  double calculateApprovalProbability(CVModel cv) {
    double score = 0;

    // الاسم والمسمى الوظيفي
    if (cv.fullName.length > 5) score += 5;
    if (cv.jobTitle.isNotEmpty) score += 5;

    // الملخص المهني (قوة المحتوى)
    if (cv.summary.length > 100) {
      score += 15;
    } else if (cv.summary.length > 50) {
      score += 10;
    }

    // معلومات التواصل والروابط
    if (cv.phone.isNotEmpty) score += 5;
    if (cv.linkedin.contains('linkedin.com')) score += 10;
    if (cv.github.contains('github.com')) score += 10;

    // الخبرات العملية
    if (cv.experiences.isNotEmpty) {
      score += 20;
      if (cv.experiences.length >= 2) score += 5;
    }

    // التعليم
    if (cv.education.isNotEmpty) score += 10;

    // المهارات
    if (cv.skills.isNotEmpty) {
      score += 5;
      if (cv.skills.length >= 4) score += 5;
    }

    // المشاريع (الإضافة الجديدة)
    if (cv.projects.isNotEmpty) {
      score += 10;
      if (cv.projects.any((p) => p.link.isNotEmpty)) score += 5; // بونص للروابط
    }

    return score.clamp(0.0, 100.0);
  }

  String getFeedback(double probability) {
    if (probability >= 90) {
      return "سيرتك الذاتية استثنائية! أنت جاهز تماماً للتقديم على كبرى الشركات.";
    } else if (probability >= 75) {
      return "سيرة ذاتية قوية جداً. فرص قبولك عالية، يمكنك تحسين الملخص المهني لزيادة القوة.";
    } else if (probability >= 50) {
      return "جيد، ولكن ينقصك بعض التفاصيل. حاول إضافة المزيد من المشاريع أو المهارات التقنية.";
    } else {
      return "السيرة الذاتية تحتاج لعمل كبير. يرجى ملء كافة الحقول وإضافة روابط أعمالك لزيادة فرصك.";
    }
  }
}
