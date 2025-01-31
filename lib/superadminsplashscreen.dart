import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/provider/super_adminauthprovider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      final authProvider = Provider.of<SuperAdminauthprovider>(context, listen: false);
      authProvider.SuperAdmincheckAuthprovider(context); // Check authentication status and navigate
    });

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background color for the splash screen
          Container(
            color: Colors.blueAccent,  // You can change the background color here
          ),
          // Animated Text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Animation (Fade-in or Scale)
              AnimatedContainer(
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                child: Image.asset(
                  'assets/golwhite.png', // Replace with your logo
                  width: 150, // Adjust the size of the logo
                  height: 150,
                ),
              ),
              const SizedBox(height: 20),
              // Text Animation (AnimatedTextKit)
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'GTEC Online Education',
                    textStyle: const TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    speed: const Duration(milliseconds: 150),
                  ),
                ],
                totalRepeatCount: 1,  // It will animate only once
                pause: const Duration(milliseconds: 1000), // Pause for a while after animation
                displayFullTextOnTap: true, // Display the full text immediately when tapped
                stopPauseOnTap: true, // Pause animation on tap
              ),
            ],
          ),
        ],
      ),
    );
  }
}