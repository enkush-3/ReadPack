import 'package:flutter/material.dart';

class MiniButton extends StatelessWidget {
  const MiniButton({
    super.key,
    required this.icon,
    this.bgcolor,
    this.icolor,
    required this.action,
  });

  final IconData icon;
  final Color? bgcolor;
  final Color? icolor;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        width: 50, 
        decoration: BoxDecoration(
          color: bgcolor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            icon,
            color: icolor,
            size: 24,
          ),
        ),
      ),
    );
  }
}