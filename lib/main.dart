import 'package:flutter/material.dart';
import 'package:invoice_app/models/invoice_data.dart';
import 'theme.dart';
import 'pages/info_page.dart';
import 'pages/product_page.dart';
import 'pages/review_page.dart';
import 'widgets/bottom_nav.dart';

void main() {
  runApp(const InvoiceApp());
}

class InvoiceApp extends StatefulWidget {
  const InvoiceApp({super.key});

  @override
  State<InvoiceApp> createState() => _InvoiceAppState();
}

class _InvoiceAppState extends State<InvoiceApp> {
  int currentIndex = 0;
  int allowedIndex = 0;

  InvoiceData invoiceData = InvoiceData.empty();

  @override
  void initState() {
    super.initState();
  }

  void _prevPage() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: Scaffold(
        body: _buildCurrentPage(),
        bottomNavigationBar: BottomNav(
          currentIndex: currentIndex,
          allowedIndex: allowedIndex,
          onTap: (index) {
            if (index <= allowedIndex) setState(() => currentIndex = index);
          },
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (currentIndex) {
      case 0:
        return InfoPage(
          invoiceData: invoiceData,
          onNext: (data) {
            setState(() {
              invoiceData = data;
              allowedIndex = 1;
              currentIndex = 1;
            });
          },
          showBack: false,
        );

      case 1:
        return ProductPage(
          invoiceData: invoiceData,
          onNext: (data) {
            setState(() {
              invoiceData = data;
              allowedIndex = 2;
              currentIndex = 2;
            });
          },
          showBack: true,
          onBack: _prevPage,
        );

      case 2:
        return ReviewPage(
          invoiceData: invoiceData,
          showBack: true,
          onBack: _prevPage,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
