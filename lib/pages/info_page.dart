import 'package:flutter/material.dart';
import 'package:invoice_app/models/invoice_data.dart';
import 'package:invoice_app/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/custom_text_field.dart';

class InfoPage extends StatefulWidget {
  final InvoiceData invoiceData;
  final void Function(InvoiceData) onNext;
  final bool showBack;
  final VoidCallback? onBack;

  const InfoPage({
    super.key,
    required this.invoiceData,
    required this.onNext,
    this.showBack = false,
    this.onBack,
  });

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  // /// COMPANY INFO
  // final companyName = TextEditingController();
  // final phoneNum = TextEditingController();

  // /// ADDRESS
  // final address1 = TextEditingController();
  // final address2 = TextEditingController();
  // final address3 = TextEditingController();
  // final address4 = TextEditingController();

  // /// INVOICE INFO
  // final invoiceDate = TextEditingController();
  // DateTime invoiceDateTime = DateTime.now();
  // final invoiceNo = TextEditingController();

  // /// TAX
  // bool sstEnabled = false;
  // bool serviceTaxEnabled = false;
  // final sstRate = TextEditingController();
  // final serviceTaxRate = TextEditingController();

  /// COMPANY INFO
  late TextEditingController companyName;
  late TextEditingController phoneNum;

  /// ADDRESS
  late TextEditingController address1;
  late TextEditingController address2;
  late TextEditingController address3;
  late TextEditingController address4;

  /// INVOICE INFO
  late TextEditingController invoiceDate;
  DateTime invoiceDateTime = DateTime.now();
  late TextEditingController invoiceNo;

  /// TAX
  bool sstEnabled = false;
  bool serviceTaxEnabled = false;
  late TextEditingController sstRate;
  late TextEditingController serviceTaxRate;

  bool _showErrors = false;

  /// ERROR MESSAGES
  String? companyNameError;
  String? phoneNumberError;
  String? address1Error;
  String? address2Error;
  String? address3Error;
  String? address4Error;
  String? invoiceDateError;
  String? invoiceNoError;

  // Button state
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    companyName = TextEditingController(text: widget.invoiceData.companyName);
    phoneNum = TextEditingController(text: widget.invoiceData.phoneNumber);
    address1 = TextEditingController(text: widget.invoiceData.address1);
    address2 = TextEditingController(text: widget.invoiceData.address2);
    address3 = TextEditingController(text: widget.invoiceData.address3);
    address4 = TextEditingController(text: widget.invoiceData.address4);

    invoiceDateTime = widget.invoiceData.invoiceDate;
    invoiceDate = TextEditingController(
      text: invoiceDateTime.toIso8601String().split("T").first,
    );
    invoiceNo = TextEditingController(text: widget.invoiceData.invoiceNo);

    sstEnabled = widget.invoiceData.sstEnabled;
    sstRate = TextEditingController(text: widget.invoiceData.sstRate ?? '0');

    serviceTaxEnabled = widget.invoiceData.serviceTaxEnabled;
    serviceTaxRate = TextEditingController(
      text: widget.invoiceData.serviceTaxRate ?? '0',
    );

    if (widget.invoiceData.companyName.isEmpty) {
      _loadStorageDefaults();
    }

    // listeners
    companyName.addListener(_updateButtonState);
    phoneNum.addListener(_updateButtonState);
    address1.addListener(_updateButtonState);
    address2.addListener(_updateButtonState);
    address3.addListener(_updateButtonState);
    address4.addListener(_updateButtonState);
    invoiceDate.addListener(_updateButtonState);
    invoiceNo.addListener(_updateButtonState);
  }

  Future<void> _loadStorageDefaults() async {
    final data = await StorageService.getCompanyInfo();
    if (!mounted) return;

    setState(() {
      companyName.text = data['name'] ?? '';
      phoneNum.text = data['phone'] ?? '';
      address1.text = data['address1'] ?? '';
      address2.text = data['address2'] ?? '';
      address3.text = data['address3'] ?? '';
      address4.text = data['address4'] ?? '';

      final nextNo = (data['lastInvoiceNum'] ?? 0) + 1;
      invoiceNo.text = 'INV-${nextNo.toString().padLeft(6, '0')}';

      sstEnabled = data['sstEnable'] ?? false;
      sstRate.text = (data['sstRate'] ?? 0).toString();

      serviceTaxEnabled = data['serviceTaxEnable'] ?? false;
      serviceTaxRate.text = (data['serviceTaxRate'] ?? 0).toString();
    });

    _updateButtonState();
  }

  void _updateButtonState() {
    isButtonEnabled.value =
        companyName.text.isNotEmpty &&
        phoneNum.text.isNotEmpty &&
        address1.text.isNotEmpty &&
        address2.text.isNotEmpty &&
        address3.text.isNotEmpty &&
        address4.text.isNotEmpty &&
        invoiceNo.text.isNotEmpty;

    if (_showErrors) {
      _validateAllFields();
    }
  }

  void _validateField(String field) {
    if (!_showErrors) return;

    setState(() {
      switch (field) {
        case 'companyName':
          companyNameError = companyName.text.isEmpty
              ? "Company Name is required"
              : null;
          break;
        case 'phoneNumber':
          phoneNumberError = phoneNum.text.isEmpty
              ? "Phone Number is required"
              : null;
          break;
        case 'address1':
          address1Error = address1.text.isEmpty
              ? "Address Line 1 is required"
              : null;
          break;
        case 'address2':
          address2Error = address2.text.isEmpty
              ? "Address Line 2 is required"
              : null;
          break;
      }
    });
  }

  void _validateAllFields() {
    _validateField('companyName');
    _validateField('phoneNumber');
    _validateField('address1');
    _validateField('address2');
    _validateField('address3');
    _validateField('address4');
    _validateField('invoiceDate');
  }

  void _onNextPressed() {
    setState(() {
      _showErrors = true;
    });

    _validateAllFields();

    if (!isButtonEnabled.value) return;

    final invoiceData = InvoiceData(
      companyName: companyName.text,
      phoneNumber: phoneNum.text,
      address1: address1.text,
      address2: address2.text,
      address3: address3.text,
      address4: address4.text,
      invoiceDate: invoiceDateTime,
      invoiceNo: invoiceNo.text,
      sstEnabled: sstEnabled,
      sstRate: sstEnabled ? sstRate.text : null,
      serviceTaxEnabled: serviceTaxEnabled,
      serviceTaxRate: serviceTaxEnabled ? serviceTaxRate.text : null,
      products: widget.invoiceData.products,
      grandTotal: 0,
    );

    widget.onNext(invoiceData);
  }

  @override
  void dispose() {
    companyName.dispose();
    phoneNum.dispose();
    address1.dispose();
    address2.dispose();
    address3.dispose();
    address4.dispose();
    invoiceDate.dispose();
    invoiceNo.dispose();
    sstRate.dispose();
    serviceTaxRate.dispose();
    isButtonEnabled.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateButtonState();
  }

  // @override
  // void initState() {
  //   super.initState();

  //   _initData();

  //   // listeners
  //   companyName.addListener(_updateButtonState);
  //   phoneNum.addListener(_updateButtonState);
  //   address1.addListener(_updateButtonState);
  //   address2.addListener(_updateButtonState);
  //   address3.addListener(_updateButtonState);
  //   address4.addListener(_updateButtonState);
  //   invoiceDate.addListener(_updateButtonState);
  //   invoiceNo.addListener(_updateButtonState);
  // }

  // Future<void> _initData() async {
  //   var data = await StorageService.getCompanyInfo();

  //   setState(() {
  //     companyName.text = data['name'];
  //     phoneNum.text = data['phone'];
  //     address1.text = data['address1'];
  //     address2.text = data['address2'];
  //     address3.text = data['address3'];
  //     address4.text = data['address4'];

  //     final nextNo = data['lastInvoiceNum'] + 1;
  //     invoiceNo.text = 'INV-${nextNo.toString().padLeft(6, '0')}';

  //     sstEnabled = data['sstEnable'] as bool? ?? false;
  //     sstRate.text = (data['sstRate'] ?? 0).toString();

  //     serviceTaxEnabled = data['serviceTaxEnable'] as bool? ?? false;
  //     serviceTaxRate.text = (data['serviceTaxRate'] ?? 0).toString();

  //     invoiceDateTime = widget.invoiceData.invoiceDate;
  //     invoiceDate.text = invoiceDateTime.toIso8601String().split("T").first;
  //   });

  //   _updateButtonState();
  // }

  // // @override
  // // void initState() {
  // //   super.initState();

  // //   final data = widget.invoiceData;
  // //   _loadSavedData();
  // //   invoiceDate.text = data.invoiceDate.toIso8601String().split("T").first;

  // //   // listeners
  // //   companyName.addListener(_updateButtonState);
  // //   phoneNum.addListener(_updateButtonState);
  // //   address1.addListener(_updateButtonState);
  // //   address2.addListener(_updateButtonState);
  // //   address3.addListener(_updateButtonState);
  // //   address4.addListener(_updateButtonState);
  // //   invoiceDate.addListener(_updateButtonState);
  // //   invoiceNo.addListener(_updateButtonState);

  // //   WidgetsBinding.instance.addPostFrameCallback((_) {
  // //     _updateButtonState();
  // //   });
  // // }

  // // void _loadSavedData() async {
  // //   var data = await StorageService.getCompanyInfo();

  // //   setState(() {
  // //     companyName.text = data['name'];
  // //     phoneNum.text = data['phone'];
  // //     address1.text = data['address1'];
  // //     address2.text = data['address2'];
  // //     address3.text = data['address3'];
  // //     address4.text = data['address4'];
  // //     final nextNo = data['lastInvoiceNum'] + 1;
  // //     invoiceNo.text = 'INV-${nextNo.toString().padLeft(6, '0')}';
  // //     sstEnabled = data['sstEnable'] as bool;
  // //     sstRate.text = data['sstRate'].toString();
  // //     // sstEnabled = data['sstEnable'].toString().toLowerCase() == 'true';
  // //     // sstRate.text = data['sstRate'];
  // //     serviceTaxEnabled = data['serviceTaxEnable'] as bool;
  // //     serviceTaxRate.text = data['serviceTaxRate'].toString();
  // //     // serviceTaxEnabled =
  // //     //     data['serviceTaxEnable'].toString().toLowerCase() == 'true';
  // //     // serviceTaxRate.text = data['serviceTaxRate'];
  // //   });
  // // }

  // void _updateButtonState() {
  //   isButtonEnabled.value =
  //       companyName.text.isNotEmpty &&
  //       phoneNum.text.isNotEmpty &&
  //       address1.text.isNotEmpty &&
  //       address2.text.isNotEmpty &&
  //       address3.text.isNotEmpty &&
  //       address4.text.isNotEmpty &&
  //       // invoiceDate.text.isNotEmpty &&
  //       invoiceNo.text.isNotEmpty;

  //   if (_showErrors) {
  //     _validateAllFields();
  //   }
  // }

  // void _validateField(String field) {
  //   if (!_showErrors) return;

  //   setState(() {
  //     switch (field) {
  //       case 'companyName':
  //         companyNameError = companyName.text.isEmpty
  //             ? "Company Name is required"
  //             : null;
  //         break;
  //       case 'phoneNumber':
  //         phoneNumberError = phoneNum.text.isEmpty
  //             ? "Phone Number is required"
  //             : null;
  //         break;
  //       case 'address1':
  //         address1Error = address1.text.isEmpty
  //             ? "Address Line 1 is required"
  //             : null;
  //         break;
  //       case 'address2':
  //         address2Error = address2.text.isEmpty
  //             ? "Address Line 2 is required"
  //             : null;
  //         break;
  //       // case 'invoiceDate':
  //       //   invoiceDateError = invoiceDate.text.isEmpty
  //       //       ? "Invoice Date is required"
  //       //       : null;
  //       //   break;
  //     }
  //   });
  // }

  // void _validateAllFields() {
  //   _validateField('companyName');
  //   _validateField('phoneNumber');
  //   _validateField('address1');
  //   _validateField('address2');
  //   _validateField('address3');
  //   _validateField('address4');
  //   _validateField('invoiceDate');
  // }

  // void _onNextPressed() {
  //   setState(() {
  //     _showErrors = true;
  //   });

  //   _validateAllFields();

  //   if (!isButtonEnabled.value) return;

  //   final invoiceData = InvoiceData(
  //     companyName: companyName.text,
  //     address1: address1.text,
  //     address2: address2.text,
  //     address3: address3.text,
  //     address4: address4.text,
  //     invoiceDate: invoiceDateTime,
  //     invoiceNo: invoiceNo.text,
  //     sstEnabled: sstEnabled,
  //     sstRate: sstEnabled ? sstRate.text : null,
  //     serviceTaxEnabled: serviceTaxEnabled,
  //     serviceTaxRate: serviceTaxEnabled ? serviceTaxRate.text : null,
  //     products: widget.invoiceData.products,
  //     grandTotal: 0,
  //     phoneNumber: phoneNum.text,
  //   );
  //   widget.onNext(invoiceData);
  // }

  // @override
  // void dispose() {
  //   companyName.dispose();
  //   phoneNum.dispose();
  //   address1.dispose();
  //   address2.dispose();
  //   address3.dispose();
  //   address4.dispose();
  //   invoiceDate.dispose();
  //   invoiceNo.dispose();
  //   sstRate.dispose();
  //   serviceTaxRate.dispose();
  //   isButtonEnabled.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: "Sales Invoice",
        showBack: widget.showBack,
        onBack: widget.onBack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// COMPANY
            const Text(
              "Company Information",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: "Company Name",
              hintText: "Company Name",
              icon: Icons.business,
              controller: companyName,
              errorText: companyNameError,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: "Phone Number",
              hintText: "Phone Number",
              icon: Icons.phone,
              controller: phoneNum,
              errorText: phoneNumberError,
            ),

            const SizedBox(height: 16),

            /// ADDRESS
            const Text(
              "Company Address",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: "Address Line 1",
              hintText: "Address Line 1",
              icon: Icons.location_on,
              controller: address1,
              errorText: address1Error,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              label: "Address Line 2",
              hintText: "Address Line 2",
              icon: Icons.location_on,
              controller: address2,
              errorText: address2Error,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              label: "Address Line 3",
              hintText: "Address Line 3",
              icon: Icons.location_on,
              controller: address3,
              errorText: address3Error,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              label: "Address Line 4",
              hintText: "Address Line 4",
              icon: Icons.location_on,
              controller: address4,
              errorText: address4Error,
            ),

            const SizedBox(height: 16),

            /// INVOICE
            const Text(
              "Invoice Information",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: "Invoice Date",
              hintText: "Invoice Date",
              icon: Icons.calendar_today,
              controller: invoiceDate,
              readOnly: true,
              errorText: invoiceDateError,
              suffix: const Icon(Icons.arrow_drop_down),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    invoiceDateTime = date;
                    invoiceDate.text = date.toIso8601String().split("T").first;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            CustomTextField(
              label: "Invoice No",
              hintText: "Invoice No",
              icon: Icons.receipt_long,
              controller: invoiceNo,
              errorText: invoiceNoError,
            ),

            const SizedBox(height: 16),

            /// TAX (optional)
            const Text(
              "Tax Information",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Switch(
                          value: sstEnabled,
                          onChanged: (val) async {
                            setState(() => sstEnabled = val);

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('sstEnable', val);
                          },
                        ),
                        // Switch(
                        //   value: sstEnabled,
                        //   onChanged: (val) => setState(() => sstEnabled = val),
                        // ),
                        const Text("SST"),
                      ],
                    ),
                    if (sstEnabled)
                      TextField(
                        controller: sstRate,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "SST Rate (%)",
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Switch(
                          value: serviceTaxEnabled,
                          onChanged: (val) async {
                            setState(() => serviceTaxEnabled = val);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('serviceTaxEnable', val);
                          },
                        ),
                        // Switch(
                        //   value: serviceTaxEnabled,
                        //   onChanged: (val) =>
                        //       setState(() => serviceTaxEnabled = val),
                        // ),
                        const Text("Service Tax"),
                      ],
                    ),
                    if (serviceTaxEnabled)
                      TextField(
                        controller: serviceTaxRate,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Service Tax Rate (%)",
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // NEXT BUTTON
            ValueListenableBuilder<bool>(
              valueListenable: isButtonEnabled,
              builder: (context, enabled, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: enabled ? _onNextPressed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: enabled ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Next"),
                  ),
                );
              },
            ),
            // ValueListenableBuilder<bool>(
            //   valueListenable: isButtonEnabled,
            //   builder: (context, enabled, child) {
            //     return SizedBox(
            //       width: double.infinity,
            //       child: ElevatedButton(
            //         onPressed: _onNextPressed,
            //         child: const Text("Next"),
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
