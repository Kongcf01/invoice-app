import 'package:flutter/material.dart';
import 'package:invoice_app/models/invoice_data.dart';
import '../widgets/app_top_bar.dart';

class ReviewPage extends StatelessWidget {
  final InvoiceData invoiceData;
  final bool showBack;
  final VoidCallback? onBack;

  const ReviewPage({
    super.key,
    required this.invoiceData,
    this.showBack = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    double subtotal = 0.0;

    for (var p in invoiceData.products) {
      final qty = double.tryParse(p.qtyController.text) ?? 0;
      final price = double.tryParse(p.priceController.text) ?? 0;
      subtotal += qty * price;
    }

    double sstAmount = 0.0;
    double serviceTaxAmount = 0.0;

    if (invoiceData.sstEnabled) {
      final rate = double.tryParse(invoiceData.sstRate ?? '0') ?? 0;
      sstAmount = subtotal * rate / 100;
    }

    if (invoiceData.serviceTaxEnabled) {
      final rate = double.tryParse(invoiceData.serviceTaxRate ?? '0') ?? 0;
      serviceTaxAmount = subtotal * rate / 100;
    }

    final grandTotal = subtotal + sstAmount + serviceTaxAmount;

    return Scaffold(
      appBar: AppTopBar(title: "Invoice", showBack: showBack, onBack: onBack),
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
                    InfoRow("Company Name", invoiceData.companyName),
                    InfoRow("Registration No", invoiceData.regNo),
                    InfoRow(
                      "Address",
                      "${invoiceData.address1}, ${invoiceData.address2}, ${invoiceData.address3}, ${invoiceData.address4}",
                    ),
                    InfoRow("Invoice Date", invoiceData.invoiceDate),
                    InfoRow("Invoice No", invoiceData.invoiceNo),
                    if (invoiceData.sstEnabled)
                      InfoRow("SST", "${invoiceData.sstRate}%"),
                    if (invoiceData.serviceTaxEnabled)
                      InfoRow("Service Tax", "${invoiceData.serviceTaxRate}%"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Products
            ...invoiceData.products.map((p) {
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
                child: SummaryRow("Grand Total", grandTotal.toStringAsFixed(2)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save),
                label: const Text("SAVE"),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
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
