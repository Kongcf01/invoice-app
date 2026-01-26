import 'package:invoice_app/pages/product_page.dart';

class InvoiceData {
  final String companyName;
  final String address1;
  final String address2;
  final String address3;
  final String address4;
  final DateTime invoiceDate;
  final String invoiceNo;
  final String phoneNumber;
  final bool sstEnabled;
  final String? sstRate;
  double? sstAmt;
  final bool serviceTaxEnabled;
  final String? serviceTaxRate;
  double? serviceTaxAmt;
  final List<ProductItem> products;
  double grandTotal;
  double grandTotalBeforeTax;

  InvoiceData({
    required this.companyName,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.address4,
    required this.invoiceDate,
    required this.invoiceNo,
    required this.sstEnabled,
    this.sstRate,
    this.sstAmt,
    required this.serviceTaxEnabled,
    this.serviceTaxRate,
    this.serviceTaxAmt,
    required this.products,
    this.grandTotal = 0,
    this.grandTotalBeforeTax = 0,
    required this.phoneNumber,
  });

  factory InvoiceData.empty() => InvoiceData(
    companyName: '',
    address1: '',
    address2: '',
    address3: '',
    address4: '',
    invoiceDate: DateTime.now(),
    invoiceNo: '',
    sstEnabled: false,
    sstRate: null,
    sstAmt: 0,
    serviceTaxEnabled: false,
    serviceTaxRate: null,
    serviceTaxAmt: 0,
    products: [],
    grandTotal: 0,
    phoneNumber: '',
  );

  InvoiceData copyWith({
    String? companyName,
    String? address1,
    String? address2,
    String? address3,
    String? address4,
    DateTime? invoiceDate,
    String? invoiceNo,
    bool? sstEnabled,
    String? sstRate,
    double? sstAmt,
    bool? serviceTaxEnabled,
    String? serviceTaxRate,
    double? serviceTaxAmt,
    List<ProductItem>? products,
    double? grandTotal,
    double? grandTotalBeforeTax,
    String? phoneNumber,
  }) {
    return InvoiceData(
      companyName: companyName ?? this.companyName,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      address3: address3 ?? this.address3,
      address4: address4 ?? this.address4,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      sstEnabled: sstEnabled ?? this.sstEnabled,
      sstRate: sstRate ?? this.sstRate,
      sstAmt: sstAmt ?? this.sstAmt,
      serviceTaxEnabled: serviceTaxEnabled ?? this.serviceTaxEnabled,
      serviceTaxRate: serviceTaxRate ?? this.serviceTaxRate,
      serviceTaxAmt: serviceTaxAmt ?? this.serviceTaxAmt,
      products: products ?? this.products,
      grandTotal: grandTotal ?? this.grandTotal,
      grandTotalBeforeTax: grandTotalBeforeTax ?? this.grandTotalBeforeTax,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
