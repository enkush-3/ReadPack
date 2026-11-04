import 'package:flutter/material.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class MiniButton extends StatelessWidget {
  final IconData icon;
  final Color? bgcolor;
  final Color? icolor;
  final VoidCallback action;

  const MiniButton({
    super.key,
    required this.icon,
    this.bgcolor,
    this.icolor,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      onTap: action,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: bgcolor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            icon,
            color: icolor,
            size: 22,
          ),
        ),
      ),
    );
  }
}
