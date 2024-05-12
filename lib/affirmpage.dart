// ignore_for_file: avoid_print, library_private_types_in_public_api, sort_child_properties_last, must_be_immutable

import 'dart:async';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:positiveme/home.dart';
import 'package:positiveme/service.dart';

class MirrorPage extends StatefulWidget {
  String name;
  MirrorPage({super.key, required this.name});

  @override
  _MirrorPageState createState() => _MirrorPageState();
}

class _MirrorPageState extends State<MirrorPage> {
  String affrim = "";

  List<String> affrimationListStrings = [
    ", you are deserving of love and respect.",
    ", you are capable of achieving your goals.",
    ", you are worthy of success and happiness.",
    ", you are enough just as you are.",
    ", you radiate positivity and confidence.",
    ", you are surrounded by abundance and opportunities.",
    ", you are resilient and can overcome any challenge.",
    ", you are making a positive impact on the world.",
    ", you are a magnet for prosperity and joy.",
    ", you are worthy of all the good things life has to offer.",
    ", you are brimming with creativity and potential.",
    ", you embrace change and adapt with ease.",
    ", you are constantly growing and evolving.",
    ", you trust in your abilities to navigate life's journey.",
    ", you attract positive, like-minded people into your life.",
    ", you are the architect of your own destiny.",
    ", you are surrounded by love and support.",
    ", you believe in yourself and your dreams.",
    ", you are a source of inspiration for others.",
    ", you approach challenges with courage and determination.",
    ", you are at peace with your past and excited for your future.",
  ];
  String getRandomAffirmation() {
    final Random random = Random();
    return affrimationListStrings[
        random.nextInt(affrimationListStrings.length)];
  }

  void changeAffirmation() {
    setState(() {
      affrim = getRandomAffirmation();
    });
  }

  bool _isLoading = true;
  late CameraController _cameraController;
  int _recordCount = 0;
  DateTime _lastRecordingTime = DateTime.now();
  bool _isRecording = false;
  final String _recognizedText = '';

  bool _isProcessing = false;
  String content = "";

  final ttsService = TTSService('Enter Key');
  @override
  void initState() {
    _initCamera();
    affrim = widget.name + getRandomAffirmation();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  bool _isLimitReached() {
    // Check if more than an hour has passed since the last recording
    if (DateTime.now().difference(_lastRecordingTime).inHours >= 1) {
      // Reset the record count if an hour has passed
      _recordCount = 0;
    }
    // Check if the recording count exceeds the limit
    return _recordCount >= 3;
  }

  void _updateRecordCount() {
    // Increment the record count
    _recordCount++;
    // Update the last recording time to the current time
    _lastRecordingTime = DateTime.now();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _cameraController = CameraController(front, ResolutionPreset.medium);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      setState(() {
        _isRecording = true;
      });
    }

    print(_recognizedText);
    affrim = widget.name + getRandomAffirmation();

    _speak(affrim);
    setState(() {
      _isProcessing = true;
      _isRecording = false;
    });
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty && !_isLimitReached()) {
      await ttsService.speak(text, 'alloy');
      _updateRecordCount();
    } else {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: const Color(0xff121212),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 400),
                  pageBuilder: (_, __, ___) => const HomeScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Opacity(
                opacity: 0.1,
                child: CameraPreview(_cameraController),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: CameraPreview(_cameraController),
            ),
            (_isProcessing)
                ? Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                              color: const Color(0xffAB72AC),
                              size: MediaQuery.sizeOf(context).height * 0.1),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.sizeOf(context).width * 0.02,
                            vertical: MediaQuery.sizeOf(context).height * 0.015,
                          ),
                          child: AnimatedTextKit(
                            isRepeatingAnimation: false,
                            animatedTexts: [
                              TypewriterAnimatedText(
                                affrim,
                                textAlign: TextAlign.center,
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.sizeOf(context).height * 0.015,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TextButton(
                            child: const Text(
                              "Finish",
                              style: TextStyle(
                                color: Colors.purple,
                                fontSize: 12,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isProcessing = false;

                                _isRecording = false;
                                affrim = "";
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    color: Colors.black54)
                : Container()
          ],
        ),
        floatingActionButton: (!_isProcessing)
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: MediaQuery.sizeOf(context).height * 0.08,
                    width: MediaQuery.sizeOf(context).height * 0.08,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xff4784B2), Color(0xffAB72AC)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )),
                  ),
                  FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    onPressed: () {
                      _toggleRecording();
                    },
                    child: Icon(
                      _isRecording ? Icons.play_arrow : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }
  }
}
