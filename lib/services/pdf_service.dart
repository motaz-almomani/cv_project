import 'package:cv_project/models/cv_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFService {
  Future<void> generateAndPrintPDF(CVModel cv) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(cv.fullName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text(cv.jobTitle, style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Email: ${cv.email}'),
                if (cv.phone.isNotEmpty) pw.Text('Phone: ${cv.phone}'),
                if (cv.github.isNotEmpty) pw.Text('GitHub: ${cv.github}'),
                if (cv.linkedin.isNotEmpty) pw.Text('LinkedIn: ${cv.linkedin}'),
              ],
            ),
            pw.Divider(),

            if (cv.summary.isNotEmpty) ...[
              pw.Text('Professional Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Paragraph(text: cv.summary),
              pw.SizedBox(height: 10),
            ],

            if (cv.skills.isNotEmpty) ...[
              pw.Text('Skills', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Bullet(text: cv.skills.join(', ')),
              pw.SizedBox(height: 10),
            ],

            if (cv.experiences.isNotEmpty) ...[
              pw.Text('Experience', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ...cv.experiences.map((exp) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('${exp.role} at ${exp.company}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(exp.duration, style: pw.TextStyle(color: PdfColors.grey)),
                  pw.SizedBox(height: 5),
                ],
              )),
              pw.SizedBox(height: 10),
            ],

            if (cv.certificates.isNotEmpty) ...[
              pw.Text('Certificates', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ...cv.certificates.map((cert) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(cert.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${cert.organization} (${cert.type})'),
                  pw.SizedBox(height: 5),
                ],
              )),
            ],
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
