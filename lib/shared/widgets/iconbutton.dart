import 'package:flutter/material.dart';

class IconButton extends StatelessWidget {
  const IconButton({
    super.key,
    required this.logolink,
    required this.action,
  });

  final String logolink;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: action,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SizedBox(
            width: 20,
            height: 20,
            child: Image.asset(logolink),
          ),
        ),
      ),
    );
  }
}