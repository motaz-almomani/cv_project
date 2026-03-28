import 'package:cv_project/models/cv_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFService {
  Future<void> generateAndPrintPDF(CVModel cv) async {
    final pdf = pw.Document();
    final template = cv.pdfTemplate;

    if (template == 'classic') {
      pdf.addPage(_classicPage(cv));
    } else if (template == 'minimal') {
      pdf.addPage(_minimalPage(cv));
    } else {
      pdf.addPage(_modernPage(cv));
    }

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.MultiPage _modernPage(CVModel cv) {
    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 16),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.indigo800, width: 3)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(cv.fullName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                  pw.Text(cv.jobTitle, style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        _contactBlock(cv),
        pw.Divider(color: PdfColors.grey400),
        ..._summaryBlock(cv),
        ..._skillsBlock(cv),
        ..._experienceBlock(cv),
        ..._educationBlock(cv),
        ..._projectsBlock(cv),
        ..._coursesBlock(cv),
        ..._certificatesBlock(cv),
      ],
    );
  }

  pw.MultiPage _classicPage(CVModel cv) {
    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(48),
      build: (pw.Context context) => [
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(cv.fullName, style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(cv.jobTitle, style: pw.TextStyle(fontSize: 13, color: PdfColors.grey800)),
              pw.SizedBox(height: 16),
              pw.Text(
                [cv.email, cv.phone, cv.linkedin, cv.github].where((s) => s.isNotEmpty).join('  •  '),
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 24),
        pw.Divider(thickness: 1),
        ..._summaryBlock(cv),
        ..._skillsBlock(cv),
        ..._experienceBlock(cv),
        ..._educationBlock(cv),
        ..._projectsBlock(cv),
        ..._coursesBlock(cv),
        ..._certificatesBlock(cv),
      ],
    );
  }

  pw.MultiPage _minimalPage(CVModel cv) {
    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 56, vertical: 48),
      build: (pw.Context context) => [
        pw.Text(cv.fullName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
        pw.SizedBox(height: 4),
        pw.Text(cv.jobTitle, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600, letterSpacing: 1.2)),
        pw.SizedBox(height: 20),
        _contactBlockMinimal(cv),
        pw.SizedBox(height: 20),
        ..._summaryBlock(cv, titleStyle: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800, letterSpacing: 2)),
        ..._skillsBlock(cv, compact: true),
        ..._experienceBlock(cv, minimal: true),
        ..._educationBlock(cv, minimal: true),
        ..._projectsBlock(cv, minimal: true),
        ..._coursesBlock(cv, compact: true),
        ..._certificatesBlock(cv, minimal: true),
      ],
    );
  }

  pw.Widget _contactBlock(CVModel cv) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (cv.email.isNotEmpty) pw.Text('Email: ${cv.email}', style: const pw.TextStyle(fontSize: 10)),
        if (cv.phone.isNotEmpty) pw.Text('Phone: ${cv.phone}', style: const pw.TextStyle(fontSize: 10)),
        if (cv.address.isNotEmpty) pw.Text('Address: ${cv.address}', style: const pw.TextStyle(fontSize: 10)),
        if (cv.github.isNotEmpty) pw.Text('GitHub: ${cv.github}', style: const pw.TextStyle(fontSize: 10)),
        if (cv.linkedin.isNotEmpty) pw.Text('LinkedIn: ${cv.linkedin}', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _contactBlockMinimal(CVModel cv) {
    final lines = <pw.Widget>[];
    if (cv.email.isNotEmpty) lines.add(pw.Text(cv.email, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)));
    if (cv.phone.isNotEmpty) lines.add(pw.Text(cv.phone, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)));
    if (cv.address.isNotEmpty) lines.add(pw.Text(cv.address, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)));
    if (cv.linkedin.isNotEmpty) lines.add(pw.Text(cv.linkedin, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)));
    if (cv.github.isNotEmpty) lines.add(pw.Text(cv.github, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)));
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: lines);
  }

  List<pw.Widget> _summaryBlock(CVModel cv, {pw.TextStyle? titleStyle}) {
    if (cv.summary.isEmpty) return [];
    final title = titleStyle ?? pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900);
    return [
      pw.Text('Summary', style: title),
      pw.SizedBox(height: 6),
      pw.Text(cv.summary, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.3)),
      pw.SizedBox(height: 12),
    ];
  }

  List<pw.Widget> _skillsBlock(CVModel cv, {bool compact = false}) {
    if (cv.skills.isEmpty) return [];
    final filtered = cv.skills.where((s) => s.trim().isNotEmpty).toList();
    if (filtered.isEmpty) return [];
    return [
      pw.Text('Skills', style: pw.TextStyle(fontSize: compact ? 11 : 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
      pw.SizedBox(height: 4),
      pw.Text(filtered.join(compact ? '  ·  ' : ', '), style: pw.TextStyle(fontSize: compact ? 9 : 11)),
      pw.SizedBox(height: 12),
    ];
  }

  List<pw.Widget> _experienceBlock(CVModel cv, {bool minimal = false}) {
    if (cv.experiences.isEmpty) return [];
    return [
      pw.Text('Experience', style: pw.TextStyle(fontSize: minimal ? 11 : 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
      pw.SizedBox(height: 6),
      ...cv.experiences.map((exp) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${exp.role} — ${exp.company}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: minimal ? 10 : 11)),
                pw.Text(exp.duration, style: pw.TextStyle(color: PdfColors.grey600, fontSize: minimal ? 8 : 9)),
              ],
            ),
          )),
      pw.SizedBox(height: 8),
    ];
  }

  List<pw.Widget> _educationBlock(CVModel cv, {bool minimal = false}) {
    if (cv.education.isEmpty) return [];
    return [
      pw.Text('Education', style: pw.TextStyle(fontSize: minimal ? 11 : 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
      pw.SizedBox(height: 6),
      ...cv.education.map((e) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(e.degree, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: minimal ? 10 : 11)),
                pw.Text('${e.institution} · ${e.year}', style: pw.TextStyle(color: PdfColors.grey600, fontSize: minimal ? 8 : 9)),
              ],
            ),
          )),
      pw.SizedBox(height: 8),
    ];
  }

  List<pw.Widget> _projectsBlock(CVModel cv, {bool minimal = false}) {
    if (cv.projects.isEmpty) return [];
    return [
      pw.Text('Projects', style: pw.TextStyle(fontSize: minimal ? 11 : 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
      pw.SizedBox(height: 6),
      ...cv.projects.map((p) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(p.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: minimal ? 10 : 11)),
                if (p.description.isNotEmpty) pw.Text(p.description, style: pw.TextStyle(fontSize: minimal ? 8 : 10)),
                if (p.link.isNotEmpty) pw.Text(p.link, style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue800)),
              ],
            ),
          )),
      pw.SizedBox(height: 8),
    ];
  }

  List<pw.Widget> _coursesBlock(CVModel cv, {bool compact = false}) {
    if (cv.courses.isEmpty) return [];
    final filtered = cv.courses.where((c) => c.trim().isNotEmpty).toList();
    if (filtered.isEmpty) return [];
    return [
      pw.Text('Courses', style: pw.TextStyle(fontSize: compact ? 11 : 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
      pw.SizedBox(height: 4),
      ...filtered.map((c) => pw.Bullet(text: c, style: pw.TextStyle(fontSize: compact ? 9 : 10))),
      pw.SizedBox(height: 8),
    ];
  }

  List<pw.Widget> _certificatesBlock(CVModel cv, {bool minimal = false}) {
    if (cv.certificates.isEmpty) return [];
    return [
      pw.Text('Certificates', style: pw.TextStyle(fontSize: minimal ? 11 : 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
      pw.SizedBox(height: 6),
      ...cv.certificates.map((cert) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(cert.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: minimal ? 10 : 11)),
                pw.Text('${cert.organization} (${cert.type})', style: pw.TextStyle(color: PdfColors.grey600, fontSize: minimal ? 8 : 9)),
              ],
            ),
          )),
    ];
  }
}
