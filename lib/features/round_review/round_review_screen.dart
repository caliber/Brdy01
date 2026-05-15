import 'package:flutter/material.dart';

class RoundReviewScreen extends StatelessWidget {
  final String roundId;
  const RoundReviewScreen({super.key, required this.roundId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('ROUND REVIEW')),
    );
  }
}
