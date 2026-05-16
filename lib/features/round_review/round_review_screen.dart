import 'package:flutter/material.dart';

class RoundReviewScreen extends StatelessWidget {
  final int roundId;
  const RoundReviewScreen({super.key, required this.roundId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('ROUND REVIEW $roundId')),
    );
  }
}
