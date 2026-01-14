import 'package:flutter/material.dart';
import 'package:invoice_app/models/invoice_data.dart';
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
  /// COMPANY INFO
  final companyName = TextEditingController();
  final regNo = TextEditingController();

  /// ADDRESS
  final address1 = TextEditingController();
  final address2 = TextEditingController();
  final address3 = TextEditingController();
  final address4 = TextEditingController();

  /// INVOICE INFO
  final invoiceDate = TextEditingController();
  final invoiceNo = TextEditingController();

  /// TAX
  bool sstEnabled = false;
  bool serviceTaxEnabled = false;
  final sstRate = TextEditingController();
  final serviceTaxRate = TextEditingController();

  bool _showErrors = false;

  /// ERROR MESSAGES
  String? companyNameError;
  String? regNoError;
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

    final data = widget.invoiceData;

    companyName.text = data.companyName;
    regNo.text = data.regNo;
    address1.text = data.address1;
    address2.text = data.address2;
    address3.text = data.address3;
    address4.text = data.address4;
    invoiceDate.text = data.invoiceDate;
    invoiceNo.text = data.invoiceNo;

    sstEnabled = data.sstEnabled;
    serviceTaxEnabled = data.serviceTaxEnabled;
    sstRate.text = data.sstRate ?? '';
    serviceTaxRate.text = data.serviceTaxRate ?? '';

    // listeners
    companyName.addListener(_updateButtonState);
    regNo.addListener(_updateButtonState);
    address1.addListener(_updateButtonState);
    address2.addListener(_updateButtonState);
    address3.addListener(_updateButtonState);
    address4.addListener(_updateButtonState);
    invoiceDate.addListener(_updateButtonState);
    invoiceNo.addListener(_updateButtonState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateButtonState();
    });
  }

  void _updateButtonState() {
    isButtonEnabled.value =
        companyName.text.isNotEmpty &&
        regNo.text.isNotEmpty &&
        address1.text.isNotEmpty &&
        address2.text.isNotEmpty &&
        address3.text.isNotEmpty &&
        address4.text.isNotEmpty &&
        invoiceDate.text.isNotEmpty &&
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
        case 'regNo':
          regNoError = regNo.text.isEmpty
              ? "Registration No is required"
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
        case 'address3':
          address3Error = address3.text.isEmpty ? "Postcode is required" : null;
          break;
        case 'address4':
          address4Error = address4.text.isEmpty
              ? "Address Line 4 is required"
              : null;
          break;
        case 'invoiceDate':
          invoiceDateError = invoiceDate.text.isEmpty
              ? "Invoice Date is required"
              : null;
          break;
        case 'invoiceNo':
          invoiceNoError = invoiceNo.text.isEmpty
              ? "Invoice No is required"
              : null;
          break;
      }
    });
  }

  void _validateAllFields() {
    _validateField('companyName');
    _validateField('regNo');
    _validateField('address1');
    _validateField('address2');
    _validateField('address3');
    _validateField('address4');
    _validateField('invoiceDate');
    _validateField('invoiceNo');
  }

  void _onNextPressed() {
    setState(() {
      _showErrors = true;
    });

    _validateAllFields();

    if (!isButtonEnabled.value) return;

    final invoiceData = InvoiceData(
      companyName: companyName.text,
      regNo: regNo.text,
      address1: address1.text,
      address2: address2.text,
      address3: address3.text,
      address4: address4.text,
      invoiceDate: invoiceDate.text,
      invoiceNo: invoiceNo.text,
      sstEnabled: sstEnabled,
      sstRate: sstEnabled ? sstRate.text : null,
      serviceTaxEnabled: serviceTaxEnabled,
      serviceTaxRate: serviceTaxEnabled ? serviceTaxRate.text : null,
      products: widget.invoiceData.products,
    );
    widget.onNext(invoiceData);
  }

  @override
  void dispose() {
    companyName.dispose();
    regNo.dispose();
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
            const SizedBox(height: 8),
            CustomTextField(
              label: "Registration No",
              hintText: "Registration No",
              icon: Icons.badge,
              controller: regNo,
              errorText: regNoError,
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
              label: "Address Line 3 (Postcode)",
              hintText: "Address Line 3 (Postcode)",
              icon: Icons.location_on,
              controller: address3,
              keyboardType: TextInputType.number,
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
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  invoiceDate.text = date.toIso8601String().split("T").first;
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
                          onChanged: (val) => setState(() => sstEnabled = val),
                        ),
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
                          onChanged: (val) =>
                              setState(() => serviceTaxEnabled = val),
                        ),
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
                    onPressed: _onNextPressed,
                    child: const Text("Next"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
