import 'package:flutter/material.dart';
import 'package:invoice_app/models/invoice_data.dart';
import 'package:invoice_app/widgets/custom_text_field.dart';
import '../widgets/app_top_bar.dart';

class ProductPage extends StatefulWidget {
  final InvoiceData invoiceData;
  final void Function(InvoiceData) onNext;
  final bool showBack;
  final VoidCallback? onBack;
  const ProductPage({
    super.key,
    required this.invoiceData,
    required this.onNext,
    this.showBack = false,
    this.onBack,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late List<ProductItem> products;
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    products = widget.invoiceData.products.isNotEmpty
        ? widget.invoiceData.products
        : [ProductItem()];

    for (final p in products) {
      p.nameController.addListener(_validateProducts);
      p.qtyController.addListener(_validateProducts);
      p.priceController.addListener(_validateProducts);
    }

    _validateProducts();
  }

  void _addProduct() {
    final product = ProductItem();

    //listeners
    product.nameController.addListener(_validateProducts);
    product.qtyController.addListener(_validateProducts);
    product.priceController.addListener(_validateProducts);

    setState(() {
      products.add(product);
    });

    _validateProducts();
  }

  void _removeProduct(int index) {
    if (products.length > 1) {
      final removed = products.removeAt(index);
      removed.dispose();
      _validateProducts();
      setState(() {});
    }
  }

  void _validateProducts() {
    bool allValid = true;
    for (var p in products) {
      if (p.nameController.text.trim().isEmpty ||
          p.qtyController.text.trim().isEmpty ||
          double.tryParse(p.qtyController.text.trim()) == null ||
          p.priceController.text.trim().isEmpty ||
          double.tryParse(p.priceController.text.trim()) == null) {
        allValid = false;
        break;
      }
    }
    isButtonEnabled.value = allValid;
  }

  @override
  void dispose() {
    isButtonEnabled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: "Products",
        showBack: widget.showBack,
        onBack: widget.onBack,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ...products.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return Column(
              children: [
                ProductCard(
                  product: product,
                  onRemove: () => _removeProduct(index),
                  showRemove: products.length > 1,
                ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),

          // Add product button
          ElevatedButton.icon(
            onPressed: _addProduct,
            icon: const Icon(Icons.add),
            label: const Text("Add Product"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),

          const SizedBox(height: 16),

          // NEXT button
          ValueListenableBuilder<bool>(
            valueListenable: isButtonEnabled,
            builder: (context, enabled, child) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: enabled
                      ? () {
                          widget.onNext(
                            widget.invoiceData.copyWith(products: products),
                          );
                        }
                      : null,

                  child: const Text("Next"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class ProductItem {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void dispose() {
    nameController.dispose();
    codeController.dispose();
    qtyController.dispose();
    priceController.dispose();
  }
}

class ProductCard extends StatelessWidget {
  final ProductItem product;
  final VoidCallback? onRemove;
  final bool showRemove;

  const ProductCard({
    super.key,
    required this.product,
    this.onRemove,
    this.showRemove = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: "Product Name *",
              hintText: "Enter product name",
              icon: Icons.production_quantity_limits,
              controller: product.nameController,
            ),
            CustomTextField(
              label: "Product Code (optional)",
              hintText: "Enter product code",
              icon: Icons.code,
              controller: product.codeController,
            ),
            CustomTextField(
              label: "Quantity *",
              hintText: "0",
              icon: Icons.format_list_numbered,
              controller: product.qtyController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            CustomTextField(
              label: "Unit Price *",
              hintText: "0.00",
              icon: Icons.attach_money,
              controller: product.priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            if (showRemove)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    "Remove",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
