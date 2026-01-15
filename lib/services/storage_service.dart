import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveCompanyInfo(String name, String phone, String address1, String address2, int lastInvoiceNum, String? address3, String? address4) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('company_name', name);
    await prefs.setString('phone_number', phone);
    await prefs.setString('company_address1', address1);
    await prefs.setString('company_address2', address2);
    await prefs.setString('company_address3', address3 ?? '');
    await prefs.setString('company_address4', address4 ?? '');
    await prefs.setInt('last_invoice_number', lastInvoiceNum);
  }

  static Future<Map<String, dynamic>> getCompanyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('company_name') ?? '',
      'phone': prefs.getString('phone_number') ?? '',
      'address1': prefs.getString('company_address1') ?? '',
      'address2': prefs.getString('company_address2') ?? '',
      'address3': prefs.getString('company_address3') ?? '',
      'address4': prefs.getString('company_address4') ?? '',
      'lastInvoiceNum': prefs.getInt('last_invoice_number') ?? 0,
    };
  }
}