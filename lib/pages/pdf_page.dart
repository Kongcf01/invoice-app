import 'dart:io';
import 'package:flutter/material.dart';
import 'package:invoice_app/models/invoice_data.dart';
import 'package:invoice_app/pages/info_page.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class PdfView extends StatelessWidget {
  final InvoiceData invoiceData;
  const PdfView({super.key, required this.invoiceData});

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();

    final receiptFormat = PdfPageFormat(80 * PdfPageFormat.mm, double.infinity);

    pdf.addPage(
  pw.Page(
    pageFormat: receiptFormat,
    margin: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    build: (context) {
      return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ===== Header =====
              pw.Text(
                invoiceData.companyName,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Address: ${invoiceData.address1} ${invoiceData.address2} ${invoiceData.address3} ${invoiceData.address4}\nTel: ${invoiceData.phoneNumber}',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 10),
              ),

              pw.SizedBox(height: 12),
              _divider(),

              pw.SizedBox(height: 6),
              pw.Text(
                'CASH RECEIPT',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 6),
              _divider(),

              // ===== Invoice Info =====
              pw.Text('Invoice No: ${invoiceData.invoiceNo}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Date: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(invoiceData.invoiceDate)}',
                  style: const pw.TextStyle(fontSize: 10)),

              pw.SizedBox(height: 10),

              // ===== Table Header =====
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Description',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Price',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Qty',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Amt',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 4),

              // ===== Items =====
              ...invoiceData.products.map(
                (item) => pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        (item.codeController.text.isNotEmpty) ? '${item.codeController.text} ${item.nameController.text}'  : item.nameController.text,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        double.parse(item.priceController.text).toStringAsFixed(2),
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        double.parse(item.qtyController.text).toStringAsFixed(2),
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        item.subtotal.toStringAsFixed(2),
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),
              _divider(),

              // ===== Total =====
              if(invoiceData.serviceTaxEnabled || invoiceData.sstEnabled)
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Total Exclude Tax',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                      child: pw.Text(
                        invoiceData.grandTotalBeforeTax.toStringAsFixed(2),
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                ],
              ),
              if(invoiceData.serviceTaxEnabled)
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Service Tax',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                      child: pw.Text(
                        (invoiceData.serviceTaxAmt ?? 0).toStringAsFixed(2),
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                ],
              ),
              if(invoiceData.sstEnabled)
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'SST',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                      child: pw.Text(
                        (invoiceData.sstAmt ?? 0).toStringAsFixed(2),
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Total',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'RM ${invoiceData.grandTotal.toStringAsFixed(2)}',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),
              _divider(),

              // ===== Footer =====
              pw.Text(
                'THANK YOU!',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 8),

              // ===== Barcode (Optional) =====
              pw.BarcodeWidget(
                data: invoiceData.invoiceNo,
                barcode: pw.Barcode.code128(),
                width: 200,
                height: 50,
              ),
            ],
          );
    },
  ),
);

    return pdf;
  }

  pw.Widget _divider() {
  return pw.Text(
    '******************************',
    textAlign: pw.TextAlign.center,
    style: const pw.TextStyle(fontSize: 10),
  );
}

  Future<void> _savePdf(BuildContext context, pw.Document pdf) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/invoice.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      body: PdfPreview(
        build: (format) async {
          final pdf = await _generatePdf();
          return pdf.save();
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'save',
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: () async {
              final pdf = await _generatePdf();
              await _savePdf(context, pdf);
              if (!context.mounted) return;
              Navigator.pop(context, true);
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'share',
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            onPressed: () async {
              final pdf = await _generatePdf();
              await Printing.sharePdf(
                bytes: await pdf.save(),
                filename: 'invoice.pdf',
              );
            },
          ),
        ],
      ),
    );
  }
}
