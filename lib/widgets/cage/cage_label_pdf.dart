import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:moustra/services/dtos/cage_dto.dart';

class CageLabelPdf {
  static pw.Document build(CageDto cage) {
    final doc = pw.Document();
    final cageLink = 'https://app.moustra.com/cage/${cage.cageUuid}';

    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          125 * PdfPageFormat.mm,
          74 * PdfPageFormat.mm,
        ),
        margin: const pw.EdgeInsets.all(4 * PdfPageFormat.mm),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Top section: info + QR
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cage info
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _infoRow('Cage Tag:', cage.cageTag),
                    _infoRow('Strain:', cage.strain?.strainName ?? ''),
                    _infoRow('Set up Date:', _formatDate(cage.createdDate)),
                    _infoRow('PI:', _ownerName(cage)),
                  ],
                ),
                // QR code
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: cageLink,
                  width: 80,
                  height: 80,
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            // Animal table
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(3),
              },
              children: [
                // Header
                pw.TableRow(
                  children: ['Tag', 'Sex', 'DOB', 'Genotype']
                      .map(
                        (h) => pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            h,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                // Animal rows
                ...cage.animals.map(
                  (a) => pw.TableRow(
                    children: [
                      _cell(a.physicalTag ?? ''),
                      _cell(a.sex ?? ''),
                      _cell(_formatDate(a.dateOfBirth)),
                      _cell(GenotypeHelper.formatGenotypes(a.genotypes)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return doc;
  }

  static pw.Widget _infoRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
            ),
            pw.SizedBox(width: 4),
            pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
      );

  static pw.Widget _cell(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(3),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 7)),
      );

  static String _ownerName(CageDto cage) =>
      '${cage.owner.user.firstName} ${cage.owner.user.lastName}'.trim();

  static String _formatDate(DateTime? d) => d != null
      ? '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}'
      : '';
}
