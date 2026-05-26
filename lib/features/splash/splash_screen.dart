import 'package:flutter/material.dart';
import '../../theme/brdy_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/bk.jpg'), context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: _IconCard()),
    );
  }
}

class _IconCard extends StatelessWidget {
  const _IconCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Stack(
        children: [
          Center(
            child: Text(
              'B',
              style: TextStyle(
                fontFamily: 'SometypeMono',
                fontSize: 68,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.0,
              ),
            ),
          ),
          Positioned(
            top: 13,
            right: 7,
            child: Text(
              '01',
              style: TextStyle(
                fontFamily: 'SometypeMono',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: -1.0,
                color: BrdyColors.accent,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
