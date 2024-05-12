// ignore_for_file: file_names, camel_case_types, library_private_types_in_public_api, use_build_context_synchronously

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:positiveme/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class namePage extends StatefulWidget {
  const namePage({super.key});

  @override
  _namePageState createState() => _namePageState();
}

class _namePageState extends State<namePage> {
  final TextEditingController _nameController = TextEditingController();
  @override
  void dispose() {
    FocusScope.of(context).unfocus();

    super.dispose();
  }

  Future<void> _saveNameToStorage(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    setState(() {});
  }

  bool animdone = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      body: (animdone)
          ? Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.sizeOf(context).width * 0.05,
                      MediaQuery.sizeOf(context).height * 0.02,
                      MediaQuery.sizeOf(context).width * 0.05,
                      MediaQuery.sizeOf(context).height * 0.02),
                  child: Column(
                    children: [
                      Expanded(
                          child: Center(
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.sizeOf(context).width *
                                            0.08),
                                child: TextField(
                                  controller: _nameController,
                                  style: const TextStyle(color: Colors.white),
                                  maxLength:
                                      12, // Limit name length for efficiency
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Color(0xff1e1e1e),
                                    hintText: 'Your Name',
                                    hintStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w200,
                                        fontSize:
                                            MediaQuery.sizeOf(context).height *
                                                0.015),
                                    border: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.sizeOf(context).width * 0.08,
                            right: MediaQuery.sizeOf(context).width * 0.08,
                            bottom: MediaQuery.sizeOf(context).height * 0.05),
                        child: SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.08,
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () async {
                              availableCameras();
                              final cameras = await availableCameras();
                              final front = cameras.firstWhere((camera) =>
                                  camera.lensDirection ==
                                  CameraLensDirection.front);

                              CameraController(front, ResolutionPreset.medium)
                                  .initialize();

                              setState(() {});
                              if (_nameController.text.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Permissions"),
                                      content: const Text(
                                          "Make sure all permissions in settings are allowed"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text("OK"),
                                          onPressed: () async {
                                            await _saveNameToStorage(
                                                _nameController.text);
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration:
                                                    const Duration(
                                                        milliseconds: 400),
                                                pageBuilder: (_, __, ___) =>
                                                    const HomeScreen(),
                                                transitionsBuilder:
                                                    (_, animation, __, child) {
                                                  return FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
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
                                        textStyle: const TextStyle(
                                            color: Colors.white),
                                        speed:
                                            const Duration(milliseconds: 300)),
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
            )
          : Center(
              child: AnimatedTextKit(
                isRepeatingAnimation: false,
                onFinished: () {
                  setState(() {
                    animdone = true;
                  });
                },
                animatedTexts: [
                  FadeAnimatedText(
                      duration: const Duration(seconds: 2),
                      "Hi there, Welcome to PositiveMe\nplease enter your name",
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.sizeOf(context).height * 0.02))
                ],
              ),
            ),
    );
  }
}
