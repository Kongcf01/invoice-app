import 'package:flutter/material.dart';
import 'package:invoice_app/pages/product_page.dart';

class InvoiceController extends ChangeNotifier {
  String companyName = '';
  String? regNo;
  String address1 = '';
  String address2 = '';
  String address3 = '';
  String address4 = '';
  DateTime? invoiceDate;
  String? invoiceNo;
  bool sstEnabled = false;
  String? sstRate;
  bool serviceTaxEnabled = false;
  String? serviceTaxRate;
  List<ProductItem> products = [];
  double totalAmount = 0.0;

  void setCompanyName(String value) {
    companyName = value;
    notifyListeners();
  }

  void setRegNo(String value) {
    regNo = value;
    notifyListeners();
  }

  void setAddress1(String value) {
    address1 = value;
    notifyListeners();
  }

  void setAddress2(String value) {
    address2 = value;
    notifyListeners();
  }

  void setAddress3(String value) {
    address3 = value;
    notifyListeners();
  }

  void setAddress4(String value) {
    address4 = value;
    notifyListeners();
  }

  void setInvoiceDate(DateTime value) {
    invoiceDate = value;
    notifyListeners();
  }

  void setInvoiceNo(String value) {
    invoiceNo = value;
    notifyListeners();
  }

  void setSstEnabled(bool value) {
    sstEnabled = value;
    notifyListeners();
  }

  void setSstRate(String value) {
    sstRate = value;
    notifyListeners();
  }

  void setServiceTaxEnabled(bool value) {
    sstEnabled = value;
    notifyListeners();
  }

  void setServiceTaxRate(String value) {
    serviceTaxRate = value;
    notifyListeners();
  }

  void addProduct(ProductItem product) {
    products.add(product);
    notifyListeners();
  }

  void removeProduct(ProductItem product) {
    products.remove(product);
    notifyListeners();
  }

  void clearProducts() {
    products.clear();
    notifyListeners();
  }

  void clearAll() {
    companyName = '';
    regNo = null;
    address1 = '';
    address2 = '';
    address3 = '';
    address4 = '';
    invoiceDate = null;
    invoiceNo = null;
    sstEnabled = false;
    sstRate = null;
    serviceTaxEnabled = false;
    serviceTaxRate = null;
    products.clear();
    notifyListeners();
  }
}