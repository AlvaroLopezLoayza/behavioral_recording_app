import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../features/abc_recording/domain/entities/abc_record.dart';
import '../../features/reliability/domain/entities/reliability_record.dart';

class ReportExportService {
  /// Exports a list of ABC records to a CSV file and triggers sharing
  static Future<void> exportAbcRecordsToCsv(List<AbcRecord> records, String patientName) async {
    final List<List<dynamic>> rows = [
      ['Date', 'Time', 'Antecedent', 'Behavior', 'Consequence', 'Duration (s)', 'Intensity', 'Type', 'Observer', 'Notes']
    ];

    for (var record in records) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(record.timestamp),
        DateFormat('HH:mm').format(record.timestamp),
        record.antecedent['description'] ?? '',
        '', // Behavior description depends on definition name, ideally passed in
        record.consequence['description'] ?? '',
        record.behaviorOccurrence.duration?.inSeconds ?? 0,
        record.behaviorOccurrence.intensity ?? '',
        record.recordingType.name,
        record.observerId,
        record.behaviorOccurrence.notes ?? '',
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/abc_export_${patientName}_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvData);

    await Share.shareXFiles([XFile(file.path)], text: 'Exportación de Datos ABC - $patientName');
  }

  /// Generates a PDF summary for a patient's behavioral assessment
  static Future<void> exportAnalysisToPdf({
    required String patientName,
    required List<AbcRecord> records,
    required Map<String, double> antecedentProbabilities,
    required Map<String, double> consequenceProbabilities,
  }) async {
    final pdf = pw.Document();
    
    final logoBytes = await rootBundle.load('assets/icon/icon.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        footer: (pw.Context context) => _buildFooter(context, logo),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Reporte de Análisis Conductual: $patientName', 
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Generado el: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'),
            pw.SizedBox(height: 10),
            pw.Text('Total de registros analizados: ${records.length}'),
            
            pw.SizedBox(height: 30),
            pw.Header(level: 1, text: 'Probabilidades Condicionales (Antecedentes)'),
            _buildProbabilityTable(antecedentProbabilities),

            pw.SizedBox(height: 30),
            pw.Header(level: 1, text: 'Probabilidades Condicionales (Consecuencias)'),
            _buildProbabilityTable(consequenceProbabilities),

            pw.SizedBox(height: 30),
            pw.Header(level: 1, text: 'Resumen de Registros Recientes'),
            pw.TableHelper.fromTextArray(
              headers: ['Fecha', 'Antecedente', 'Consecuencia', 'Tipo'],
              data: records.take(15).map((r) => [
                DateFormat('dd/MM HH:mm').format(r.timestamp),
                r.antecedent['description'] ?? '',
                r.consequence['description'] ?? '',
                r.recordingType.name,
              ]).toList(),
            ),
          ];
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/analisis_${patientName}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Reporte de Análisis - $patientName');
  }

  static pw.Widget _buildProbabilityTable(Map<String, double> probabilities) {
    final entries = probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.TableHelper.fromTextArray(
      headers: ['Variable', 'Probabilidad (%)'],
      data: entries.map((e) => [
        e.key,
        '${(e.value * 100).toStringAsFixed(1)}%',
      ]).toList(),
    );
  }

  /// Exports an IOA Reliability report to PDF
  static Future<void> exportReliabilityReport(ReliabilityRecord record, String patientName, String behaviorName) async {
    final pdf = pw.Document();
    
    final logoBytes = await rootBundle.load('assets/icon/icon.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: 'Reporte de Fiabilidad (IOA)'),
              pw.SizedBox(height: 20),
              pw.Text('Paciente: $patientName'),
              pw.Text('Conducta: $behaviorName'),
              pw.Text('Fecha: ${DateFormat('dd/MM/yyyy').format(record.createdAt)}'),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                   pw.Text('Método utilizado:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                   pw.Text(record.method),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                   pw.Text('Puntaje de Acuerdo:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                   pw.Text('${record.score.toStringAsFixed(2)}%', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.green)),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Text('Rango de Tiempo Analizado:'),
              pw.Text('${DateFormat('HH:mm').format(record.startTime)} - ${DateFormat('HH:mm').format(record.endTime)}'),
              pw.Spacer(),
              pw.Text('Firmado por el supervisor de Senda', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey)),
              pw.SizedBox(height: 10),
              _buildFooter(context, logo),
            ],
          );
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/ioa_${patientName}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Reporte IOA - $patientName');
  }

  static pw.Widget _buildFooter(pw.Context context, pw.MemoryImage logo) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'hecho con Senda',
            style: pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 10,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Image(logo, width: 24, height: 24),
        ],
      ),
    );
  }
}
