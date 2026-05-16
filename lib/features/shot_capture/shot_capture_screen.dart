import 'package:flutter/material.dart';

class ShotCaptureScreen extends StatelessWidget {
  final int roundId;
  const ShotCaptureScreen({super.key, required this.roundId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('ROUND $roundId')),
    );
  }
}
