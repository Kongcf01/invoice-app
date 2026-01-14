import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final int allowedIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.allowedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0288D1);
    const selectedColor = Color.fromARGB(255, 245, 225, 7);
    const unselectedColor = Colors.white70;

    final items = const [
      BottomNavigationBarItem(icon: Icon(Icons.info), label: "Info"),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: "Products",
      ),
      BottomNavigationBarItem(icon: Icon(Icons.check), label: "Review"),
    ];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index <= allowedIndex) onTap(index);
      },
      items: items
          .asMap()
          .entries
          .map(
            (entry) => BottomNavigationBarItem(
              icon: entry.value.icon,
              label: entry.value.label,
              tooltip: entry.key <= allowedIndex ? entry.value.label : null,
            ),
          )
          .toList(),
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      backgroundColor: backgroundColor,
      type: BottomNavigationBarType.fixed,
    );
  }
}
