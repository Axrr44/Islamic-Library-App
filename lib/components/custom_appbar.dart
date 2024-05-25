import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final double height;
  final Color color;
  final Alignment alignment;

  const CustomAppBar({super.key, 
    required this.child,
    this.height = kToolbarHeight,
    this.color = Colors.grey,
    this.alignment = Alignment.center,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      color: color,
      alignment: alignment,
      child: child,
    );
  }
}