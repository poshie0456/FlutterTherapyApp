import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:positiveme/camera_page.dart';
import 'package:video_player/video_player.dart';

class welcomeAI extends StatefulWidget {
  String name;

  welcomeAI(this.name, {super.key});
  @override
  _welcomeAIState createState() => _welcomeAIState();
}

class _welcomeAIState extends State<welcomeAI> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.asset('assets/process.mp4')
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true)
      ..play();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.2,
            child: Expanded(child: VideoPlayer(_videoPlayerController)),
          ),
          Center(
            child: AnimatedTextKit(
              isRepeatingAnimation: false,
              onFinished: () {
                setState(() {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 400),
                      pageBuilder: (_, __, ___) => const CameraPage(),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                });
              },
              animatedTexts: [
                FadeAnimatedText(
                    duration: const Duration(seconds: 2),
                    "Hi ${widget.name}\nI am so happy you're here",
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.sizeOf(context).height * 0.02))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
