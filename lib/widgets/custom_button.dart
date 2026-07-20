import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color>? gradientColors;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? [Colors.indigo, Colors.purple];
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
