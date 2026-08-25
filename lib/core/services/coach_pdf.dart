import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../calc/coach_math.dart';
import '../../models/coach_models.dart';

class CoachPdf {
  CoachPdf._();

  static const disclaimer =
      'CoachBoard is a coaching log. It does not provide medical diagnosis, treatment, or advice. Measurements are records you enter — not clinical findings.';

  static Future<void> shareProgress({
    required Athlete client,
    required List<TrainingSession> sessions,
    required double attendance,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) => [
          pw.Text('CoachBoard', style: const pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF1F3D12))),
          pw.Text('Progress report — ${client.name}'),
          pw.Divider(),
          pw.Text('Goal: ${client.goal}'),
          pw.Text('Attendance (this month): ${CoachMath.percent(attendance)}'),
          pw.SizedBox(height: 12),
          pw.Text('Measurements (lb)', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          if (client.measures.isEmpty) pw.Text('No logs yet.')
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Date', 'Weight (lb)'],
              data: [
                for (final m in client.measures)
                  [DateFormat.yMMMd().format(m.at), m.weightLb.toStringAsFixed(1)],
              ],
            ),
          pw.SizedBox(height: 12),
          pw.Text('Recent sessions', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          for (final s in sessions.take(12))
            pw.Bullet(text: '${DateFormat.MMMd().add_jm().format(s.at)} · ${s.title} · ${s.attended ? 'Present' : 'Open'}'),
          if (client.notes.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text('Coach notes'),
            pw.Text(client.notes),
          ],
          pw.SizedBox(height: 24),
          pw.Text(disclaimer, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ],
      ),
    );
    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/progress-${client.id}.pdf');
    await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);
    await Share.shareXFiles([XFile(file.path, mimeType: 'application/pdf', name: 'progress-${client.nickname.isEmpty ? client.name : client.nickname}.pdf')]);
  }
}
