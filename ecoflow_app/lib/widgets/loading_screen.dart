import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade800,
              Colors.green,
              Colors.green.shade900
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 150,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 70,
                height: 70,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballBeat,
                  colors: const [
                    Colors.greenAccent,
                    Colors.white,
                    Colors.lightGreenAccent,
                    Colors.limeAccent
                  ],
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(height: 20),
              DefaultTextStyle(
                style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700),
                child: AnimatedTextKit(
                  animatedTexts: [
                    RotateAnimatedText('Initializing EcoFlow...'),
                    RotateAnimatedText('Connecting to sensors...'),
                    RotateAnimatedText('Testing the water pumps...'),
                    RotateAnimatedText('Getting data ready...')
                  ],
                  repeatForever: true,
                  pause: const Duration(milliseconds: 500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
