import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_app/models/invoice_data.dart';
import 'package:invoice_app/pages/pdf_page.dart';
import 'package:invoice_app/services/storage_service.dart';
import '../widgets/app_top_bar.dart';

class ReviewPage extends StatefulWidget {
  final InvoiceData invoiceData;
  final void Function(InvoiceData) onPdfSaved;
  final bool showBack;
  final VoidCallback? onBack;

  const ReviewPage({
    super.key,
    required this.invoiceData,
    required this.onPdfSaved,
    this.showBack = false,
    this.onBack,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  void onIssueInvoice() async {
    final rawInvoiceNo = widget.invoiceData.invoiceNo
        .replaceFirst('INV-', '')
        .replaceFirst(RegExp(r'^0+'), '');

    final invoiceNoInt = int.parse(rawInvoiceNo.isEmpty ? '0' : rawInvoiceNo);
    await StorageService.saveCompanyInfo(
      widget.invoiceData.companyName,
      widget.invoiceData.phoneNumber,
      widget.invoiceData.address1,
      widget.invoiceData.address2,
      invoiceNoInt,
      widget.invoiceData.address3,
      widget.invoiceData.address4,
      widget.invoiceData.sstEnabled,
      int.parse(widget.invoiceData.sstRate ?? '0'),
      widget.invoiceData.serviceTaxEnabled,
      int.parse(widget.invoiceData.serviceTaxRate ?? '0'),
    );
  }

  Future<void> _openPdf(BuildContext context) async {
    onIssueInvoice();
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PdfView(invoiceData: widget.invoiceData),
      ),
    );

    if (saved == true) {
      widget.onPdfSaved(InvoiceData.empty());
    }
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = 0.0;

    for (var p in widget.invoiceData.products) {
      final qty = double.tryParse(p.qtyController.text) ?? 0;
      final price = double.tryParse(p.priceController.text) ?? 0;
      subtotal += qty * price;
    }

    double sstAmount = 0.0;
    double serviceTaxAmount = 0.0;

    if (widget.invoiceData.sstEnabled) {
      final rate = double.tryParse(widget.invoiceData.sstRate ?? '0') ?? 0;
      sstAmount = subtotal * rate / 100;
    }

    if (widget.invoiceData.serviceTaxEnabled) {
      final rate =
          double.tryParse(widget.invoiceData.serviceTaxRate ?? '0') ?? 0;
      serviceTaxAmount = subtotal * rate / 100;
    }

    widget.invoiceData.grandTotal = subtotal + sstAmount + serviceTaxAmount;

    return Scaffold(
      appBar: AppTopBar(
        title: "Invoice",
        showBack: widget.showBack,
        onBack: widget.onBack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoRow("Company Name", widget.invoiceData.companyName),
                    InfoRow("Phone Number", widget.invoiceData.phoneNumber),
                    InfoRow(
                      "Address",
                      "${widget.invoiceData.address1}, ${widget.invoiceData.address2}, ${widget.invoiceData.address3}, ${widget.invoiceData.address4}",
                    ),
                    InfoRow(
                      "Invoice Date",
                      DateFormat(
                        'dd/MM/yyyy HH:mm:ss',
                      ).format(widget.invoiceData.invoiceDate),
                    ),
                    InfoRow("Invoice No", widget.invoiceData.invoiceNo),
                    if (widget.invoiceData.sstEnabled)
                      InfoRow("SST", "${widget.invoiceData.sstRate}%"),
                    if (widget.invoiceData.serviceTaxEnabled)
                      InfoRow(
                        "Service Tax",
                        "${widget.invoiceData.serviceTaxRate}%",
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Products
            ...widget.invoiceData.products.map((p) {
              final qty = double.tryParse(p.qtyController.text) ?? 0;
              final price = double.tryParse(p.priceController.text) ?? 0;
              final subtotal = qty * price;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRow("Product Name", p.nameController.text),
                      if (p.codeController.text.isNotEmpty)
                        InfoRow("Product Code", p.codeController.text),
                      InfoRow("Quantity", qty.toString()),
                      InfoRow("Unit Price", price.toStringAsFixed(2)),
                      InfoRow("Subtotal", subtotal.toStringAsFixed(2)),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SummaryRow(
                  "Grand Total",
                  widget.invoiceData.grandTotal.toStringAsFixed(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton.icon(
            //     onPressed: () {},
            //     icon: const Icon(Icons.save),
            //     label: const Text("SAVE"),
            //   ),
            // ),
            // const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  _openPdf(context);
                },
                icon: const Icon(Icons.print),
                label: const Text("PRINT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const SummaryRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
                softWrap: true,
                maxLines: 3,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
