// ignore_for_file: avoid_print, library_private_types_in_public_api, sort_child_properties_last

import 'dart:async';
import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:positiveme/home.dart';
import 'package:positiveme/service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isLoading = true;
  int _recordCount = 0;
  DateTime _lastRecordingTime = DateTime.now();

  late CameraController _cameraController;
  late stt.SpeechToText _speech;
  bool _isRecording = false;
  String _recognizedText = '';

  bool _isProcessing = false;
  String content = "";
  late Timer _timer;
  final ttsService = TTSService('Enter open ai key');
  @override
  void initState() {
    _initCamera();
    _initSpeechToText();

    _initTts();

    super.initState();
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

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _cameraController = CameraController(front, ResolutionPreset.medium);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  _initSpeechToText() {
    _speech = stt.SpeechToText();
    _speech.initialize();
  }

  Future<void> _toggleRecording() async {
    // Check if the limit is reached
    if (!_isLimitReached()) {
      // If not reached, update the record count and proceed with recording

      if (!_isRecording) {
        setState(() {
          _isRecording = true;
        });

        // Start the timer with a limit of 10 seconds
        _timer = Timer(const Duration(seconds: 8), () {
          _speech.stop();

          setState(() {
            _isProcessing = true;
            _isRecording = false;
          });
          getChatResponse();
        });

        bool available = await _speech.initialize(
          onStatus: (status) {
            print('Speech recognition status: $status');
          },
          onError: (errorNotification) {
            print('Error: $errorNotification');
          },
        );

        if (available) {
          _speech.listen(
            onResult: (result) {
              setState(() {
                _recognizedText = result.recognizedWords;
                _isRecording = true;
              });
            },
          );
        }
      } else {
        print(_recognizedText);
        _speech.stop();

        _timer.cancel(); // Cancel the timer
        setState(() {
          _isProcessing = true;
          _isRecording = false;
        });

        setState(() {
          getChatResponse();
          _updateRecordCount();
        });
      }
    } else {
      // If limit reached, show a message or take appropriate action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recording limit reached for this hour'),
        ),
      );
    }
  }

  _initTts() {}

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await ttsService.speak(text, 'alloy');
    } else {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> getChatResponse() async {
    const String endpoint = 'https://api.openai.com/v1/chat/completions';
    final String request = _recognizedText;

    final Map<String, dynamic> requestData = {
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'user',
          'content':
              'Give a response to this in quotes, the text might be resposnible, give the user positive affirmations where possible:$request'
        }
      ],
      'max_tokens': 80
    };

    final http.Response response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer Enter key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      // Handle the response data here
      setState(() {
        content = data['choices'][0]['message']['content'].toString();
        setState(() {});
        print("ChatGpt response$content");

        _speak(content);
      });
    } else {
      // Handle errors
      print('Request failed with status: ${response.statusCode}');
      content = response.body;
      setState(() {});
      print('Response body: ${response.body}');
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
            icon: const Icon(Icons.arrow_back_outlined),
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
          foregroundColor: Colors.white,
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
                            size: MediaQuery.sizeOf(context).height * 0.1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.sizeOf(context).width * 0.02,
                            vertical: MediaQuery.sizeOf(context).height * 0.015,
                          ),
                          child: AnimatedTextKit(
                            totalRepeatCount: 3,
                            isRepeatingAnimation: true,
                            animatedTexts: [
                              TypewriterAnimatedText(
                                content,
                                textAlign: TextAlign.center,
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.sizeOf(context).width * 0.02,
                            vertical: MediaQuery.sizeOf(context).height * 0.015,
                          ),
                          child: TextButton(
                            child: Text(
                              "Finish",
                              style: TextStyle(
                                color: Colors.purple,
                                fontSize:
                                    MediaQuery.sizeOf(context).height * 0.015,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isProcessing = false;

                                _isRecording = false;
                                content = "";
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
                      _isRecording ? Icons.stop : Icons.mic,
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
