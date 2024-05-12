// ignore_for_file: library_private_types_in_public_api

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:positiveme/namePage.dart';
import 'package:video_player/video_player.dart';

class OnBoardPages extends StatefulWidget {
  const OnBoardPages({super.key});

  @override
  _OnBoardPagesState createState() => _OnBoardPagesState();
}

class _OnBoardPagesState extends State<OnBoardPages> {
  final PageController _controller = PageController();

  VideoPlayerController? _videoController;
  int _currentPage = 0;
  @override
  void dispose() {
    _controller.dispose();
    _videoController?.dispose();

    FocusScope.of(context).unfocus();

    super.dispose();
  }

  Future<void> _initializeVideoController() async {
    _videoController = VideoPlayerController.asset("assets/video.mp4");
    await _videoController!.initialize();
    setState(() {
      _videoController!.play();
      _videoController!.setLooping(true);
    });
  }

  @override
  void initState() {
    _initializeVideoController();
    super.initState();
  }

  final List<OnBoardPageItem> onBoardPageItems = [
    OnBoardPageItem(
      animation: 'assets/collab.json',
      title: 'PositiveMe AI',
      description:
          'Talk with AI powered by ChatGPT 3.5 for venting, affirmation and therapeutic assstance.',
    ),
    OnBoardPageItem(
      animation: 'assets/loader.json',
      title: 'Magic Mirror',
      description:
          'The magic mirror allows you to talk to AI in real time, with voice activated functionality and hyper-realistic voice technology powered by OpenAI to provide the perfect experience',
    ),
    OnBoardPageItem(
      animation: 'assets/book.json',
      title: 'Journal',
      description:
          'Journal Your Thoughts and daily life with built-in note-taking functionality',
    ),
    // Add more onboarding items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Expanded(
              child:
                  Opacity(opacity: 0.2, child: VideoPlayer(_videoController!))),
          Padding(
            padding: EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width * 0.05,
              MediaQuery.of(context).size.height * 0.1,
              MediaQuery.of(context).size.width * 0.05,
              MediaQuery.of(context).size.height * 0.015,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset("assets/applogo.png"),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    onPageChanged: (value) {
                      setState(() {
                        _currentPage = value;
                      });
                    },
                    controller: _controller,
                    itemCount: onBoardPageItems.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: OnBoardPage(
                              onBoardPageItem: onBoardPageItems[index],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: MediaQuery.sizeOf(context).height * 0.01,
                      height: MediaQuery.sizeOf(context).height * 0.01,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? const Color(0xffAB72AC)
                            : Colors.grey,
                      ),
                    );
                  }),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.04,
                    right: MediaQuery.of(context).size.width * 0.04,
                    bottom: MediaQuery.of(context).size.height * 0.06,
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.08,
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const namePage(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 300),
                          ),
                        );
                      },
                      child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xff4784B2),
                                Color(0xffAB72AC)
                              ]),
                              borderRadius: BorderRadius.circular(20)),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              WavyAnimatedText("Continue",
                                  textStyle:
                                      const TextStyle(color: Colors.white),
                                  speed: const Duration(milliseconds: 300)),
                            ],
                            pause: const Duration(seconds: 3),
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnBoardPageItem {
  final String title;
  final String description;
  final String animation;

  OnBoardPageItem({
    required this.title,
    required this.description,
    required this.animation,
  });
}

class OnBoardPage extends StatelessWidget {
  final OnBoardPageItem onBoardPageItem;

  const OnBoardPage({super.key, required this.onBoardPageItem});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          onBoardPageItem.animation,
          width: MediaQuery.of(context).size.height * 0.286,
          height: MediaQuery.of(context).size.height * 0.286,
          fit: BoxFit.fill,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.024),
        Text(
          onBoardPageItem.title,
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.055,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.012),
        Text(
          onBoardPageItem.description,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.035,
              color: Colors.white),
        ),
      ],
    );
  }
}
