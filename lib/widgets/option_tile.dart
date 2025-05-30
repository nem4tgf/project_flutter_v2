import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey;
    Color textColor = Colors.black;

    if (isSelected) {
      if (isCorrect) {
        bgColor = Colors.green[300]!;
        borderColor = Colors.green;
        textColor = Colors.white;
      } else {
        bgColor = Colors.red[300]!;
        borderColor = Colors.red;
        textColor = Colors.white;
      }
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          option,
          style: TextStyle(fontSize: 18, color: textColor),
        ),
      ),
    );
  }
}
