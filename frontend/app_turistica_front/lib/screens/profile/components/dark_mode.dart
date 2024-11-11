import 'package:flutter/material.dart';

class DarkModeSwitch extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggle;

  const DarkModeSwitch({
    Key? key,
    required this.isDarkMode,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Dark Mode",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}