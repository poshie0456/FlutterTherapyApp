import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:positiveme/affirmpage.dart';
import 'package:video_player/video_player.dart';

class AffrimProcess extends StatefulWidget {
  String name;

  AffrimProcess(this.name);
  @override
  _welcomeAIState createState() => _welcomeAIState();
}

class _welcomeAIState extends State<AffrimProcess> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.asset('assets/process.mp4')
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true)
      ..play();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                      pageBuilder: (_, __, ___) =>
                          MirrorPage(name: widget.name),
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
                    duration: Duration(seconds: 2),
                    "Hi ${widget.name}\nI am here to affirm you",
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
