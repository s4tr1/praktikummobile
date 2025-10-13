import 'package:flutter/material.dart';

class RotatingLogo extends StatelessWidget {
  final AnimationController controller;

  const RotatingLogo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: controller,
      child: Image.asset('assets/logo.jpg', height: 120),
    );
  }
}
