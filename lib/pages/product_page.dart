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
    setState(() {});
  }

  double get grandTotal {
    return products.fold(0, (sum, p) => sum + p.subtotal);
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
                ProductBlock(
                  product: product,
                  onRemove: () => _removeProduct(index),
                  showRemove: products.length > 1,
                ),
                const Divider(height: 32),
              ],
            );
          }),

          ElevatedButton.icon(
            onPressed: _addProduct,
            icon: const Icon(Icons.add),
            label: const Text("Add Product"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),

          const SizedBox(height: 24),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Grand Total",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                grandTotal.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Next"),
                ),
              );
            },
          ),
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

  double get subtotal {
    final qty = double.tryParse(qtyController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0;
    return qty * price;
  }

  void dispose() {
    nameController.dispose();
    codeController.dispose();
    qtyController.dispose();
    priceController.dispose();
  }
}

class ProductBlock extends StatelessWidget {
  final ProductItem product;
  final VoidCallback? onRemove;
  final bool showRemove;

  const ProductBlock({
    super.key,
    required this.product,
    this.onRemove,
    this.showRemove = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
            label: "Product Code (Optional)",
            hintText: "Enter product code",
            icon: Icons.code,
            controller: product.codeController,
          ),
          CustomTextField(
            label: "Quantity *",
            hintText: "0",
            icon: Icons.format_list_numbered,
            controller: product.qtyController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          CustomTextField(
            label: "Unit Price *",
            hintText: "0.00",
            icon: Icons.attach_money,
            controller: product.priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Subtotal: ${product.subtotal.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          if (showRemove) const SizedBox(height: 10),

          if (showRemove)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.delete, color: Colors.red, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "Remove",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
