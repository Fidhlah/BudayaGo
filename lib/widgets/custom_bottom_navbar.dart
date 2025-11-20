import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: currentIndex == 0 ? Colors.orange.shade700 : Colors.grey,
            ),
            onPressed: () => onTap(0),
          ),
          const SizedBox(width: 40),
          IconButton(
            icon: Icon(
              Icons.person,
              color: currentIndex == 1 ? Colors.orange.shade700 : Colors.grey,
            ),
            onPressed: () => onTap(1),
          ),
        ],
      ),
    );
  }
}
