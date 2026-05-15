import 'package:flutter/material.dart';

class ShotCaptureScreen extends StatelessWidget {
  final String roundId;
  final int holeNumber;
  const ShotCaptureScreen({super.key, required this.roundId, required this.holeNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('HOLE $holeNumber')),
    );
  }
}
