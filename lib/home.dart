// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, avoid_print, unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:positiveme/affrimprocess.dart';
import 'package:positiveme/diary.dart';
import 'package:positiveme/welcomeAI.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController _controller;
  late PageController _pageController;

  int currindex = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(); // Initialize PageController

    _controller = VideoPlayerController.asset('assets/video.mp4')
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true)
      ..play();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose(); // Dispose PageController
    super.dispose();
  }

  void checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    print(connectivityResult);
    if (connectivityResult == ConnectivityResult.none) {
      // Show dialog for no internet connection
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("No Internet Connection"),
            content: const Text(
                "Please check your internet connection and try again."),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Navigate to the CameraPage
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              welcomeAI(_AffirmationWidgetState.s_name),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              )),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _controller.value.isInitialized
              ? Expanded(
                  child: Opacity(
                    opacity: 0.2,
                    child: VideoPlayer(_controller),
                  ),
                )
              : Container(),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width *
                      0.05, // 30 / 695 (iPhone 15 Pro Max width)
                  MediaQuery.of(context).size.height *
                      0.08, // 60 / 834 (iPhone 15 Pro Max height)
                  MediaQuery.of(context).size.width *
                      0.05, // 30 / 695 (iPhone 15 Pro Max width)
                  MediaQuery.of(context).size.height *
                      0.02, // 20 / 834 (iPhone 15 Pro Max height)
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.02,
                    child: Image.asset("assets/applogo.png"),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.sizeOf(context).width * 0.05,
                      MediaQuery.sizeOf(context).height * 0.02,
                      MediaQuery.sizeOf(context).width * 0.05,
                      MediaQuery.sizeOf(context).height * 0.02),
                  child: PageView(
                    onPageChanged: (index) {
                      setState(() {
                        currindex = index;
                      });
                    },

                    controller:
                        _pageController, // Set the controller for PageView
                    children: [
                      AffirmationWidget(),
                      DiaryHomePage()
                      //journalPage(),
                    ],
                  ),
                ),
              ),
              SizedBox(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.sizeOf(context).height * 0.02,
                      horizontal: MediaQuery.sizeOf(context).width * 0.05),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(30)),
                    padding: EdgeInsets.all(
                        MediaQuery.sizeOf(context).height * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    spreadRadius: 2,
                                    blurRadius: 2)
                              ],
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(30)),
                          child: FloatingActionButton(
                            onPressed: () {
                              // Go to previous page
                              _pageController.previousPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                              setState(() {
                                currindex = 0;
                              });
                            },
                            backgroundColor: Colors.transparent,
                            child: Icon(Icons.home_outlined,
                                color: (currindex == 0)
                                    ? const Color(0xff4784B2)
                                    : Colors.white),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [
                                    Color(0xff4784B2),
                                    Color(0xffAB72AC)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter),
                              borderRadius: BorderRadius.circular(30)),
                          child: FloatingActionButton(
                            onPressed: () {
                              checkInternetConnection();
                            },
                            backgroundColor: Colors.transparent,
                            child: const Icon(
                              Icons.animation_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(30)),
                          child: FloatingActionButton(
                            onPressed: () {
                              _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                              setState(() {
                                currindex = 1;
                              });
                            },
                            backgroundColor: Colors.transparent,
                            child: Icon(Icons.book_outlined,
                                color: (currindex == 1)
                                    ? const Color(0xffAB72AC)
                                    : Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class AffirmationWidget extends StatefulWidget {
  const AffirmationWidget({
    Key? key,
  }) : super(key: key);

  @override
  _AffirmationWidgetState createState() => _AffirmationWidgetState();
}

class _AffirmationWidgetState extends State<AffirmationWidget> {
  // ignore: prefer_final_fields
  TextEditingController _editNameController = TextEditingController();
  List<String> affirmations = [
    "I am worthy of all the good things life has to offer.",
    "I trust the journey, even when I do not understand it.",
    "I am constantly evolving and improving.",
    "I am surrounded by love and support.",
    "I attract positivity into my life effortlessly.",
    "I am capable of overcoming any obstacle that comes my way.",
    "I am deserving of success and happiness.",
    "I am grateful for all the lessons life teaches me.",
    "I radiate confidence and inner peace.",
    "I choose to focus on the present moment and let go of the past.",
    "I am at peace with who I am and where I am going.",
    "I am resilient, strong, and capable of achieving my goals.",
    "I am filled with boundless energy and enthusiasm for life.",
    "I am open to receiving all the blessings the universe has in store for me.",
    "I trust in the timing of my life.",
    "I am free to create the life of my dreams.",
    "I forgive myself and others, releasing any resentment or negativity.",
    "I am a beacon of light, shining brightly wherever I go.",
    "I am in tune with my intuition and trust its guidance.",
    "I attract positive, uplifting people into my life.",
    "I am aligned with my purpose and passion.",
    "I am worthy of love and respect.",
    "I am grateful for the abundance that surrounds me.",
    "I choose joy and optimism every day.",
    "I am a source of inspiration and positivity for others.",
    "I believe in my ability to make a difference in the world.",
    "I am the master of my thoughts and emotions.",
    "I am constantly expanding my comfort zone and embracing new experiences.",
    "I am a magnet for success, prosperity, and abundance.",
    "I am enough, just as I am.",
    "I am worthy of my dreams and desires.",
    "I release the need for perfection and embrace my authenticity.",
    "I am connected to the infinite wisdom of the universe.",
    "I am grateful for the gift of life and all its possibilities.",
    "I trust that everything is unfolding for my highest good.",
    "I am capable of achieving anything I set my mind to.",
    "I am grateful for the journey of self-discovery and personal growth.",
    "I am worthy of happiness, love, and fulfillment.",
    "I am a unique and valuable individual, worthy of respect and admiration.",
    "I am surrounded by abundance and prosperity in all areas of my life.",
    "I am a powerful creator, shaping my reality with my thoughts and beliefs.",
    "I am open to receiving love, joy, and abundance in all its forms.",
    "I am resilient and capable of overcoming any challenge.",
    "I am at peace with my past, present, and future.",
    "I am deserving of all the blessings life has to offer.",
    "I am grateful for the opportunity to learn and grow every day.",
    "I am worthy of success, happiness, and fulfillment.",
    "I am confident in my ability to achieve my goals.",
    "I am worthy of love and acceptance, just as I am.",
    "I am grateful for the abundance that flows into my life.",
    "I am surrounded by love, light, and positivity.",
    "I am aligned with the energy of abundance and prosperity.",
    "I am worthy of all the good things life has to offer.",
    "I am deserving of love, respect, and kindness.",
    "I am grateful for the opportunity to create the life of my dreams.",
    "I am capable of achieving greatness.",
    "I am worthy of success, happiness, and fulfillment.",
    "I am grateful for the abundance that flows into my life.",
    "I am surrounded by love, light, and positivity.",
    "I am aligned with the energy of abundance and prosperity.",
    "I am worthy of all the good things life has to offer.",
    "I am deserving of love, respect, and kindness.",
    "I am grateful for the opportunity to create the life of my dreams.",
    "I am capable of achieving greatness."
  ];

  String? randomAffirmation;

  int currindex = 0;
  static String s_name = "";
  Future<void> _loadNameFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedName = prefs.getString('name') ?? '';
    s_name = storedName;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadNameFromStorage();
    randomAffirmation = getRandomAffirmation();
  }

  String getRandomAffirmation() {
    final Random random = Random();
    return affirmations[random.nextInt(affirmations.length)];
  }

  void changeAffirmation() {
    setState(() {
      randomAffirmation = getRandomAffirmation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 100,
          child: TextButton(
            child: Text(
              "Hi $s_name",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: MediaQuery.sizeOf(context).height * 0.02,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              setState(() {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.black,
                      title: const Text(
                        'Edit Name',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: TextField(
                        style: const TextStyle(color: Colors.white),
                        maxLines: null,
                        controller: _editNameController,
                        decoration: const InputDecoration(
                            hintText: 'Enter your name',
                            hintStyle: TextStyle(color: Colors.white)),
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _loadNameFromStorage();
                            });
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _saveNameToStorage(_editNameController.text);
                            setState(() {
                              _loadNameFromStorage();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                );
              });
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => changeAffirmation(),
                child: Center(
                  child: Text(
                    randomAffirmation!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MediaQuery.sizeOf(context).height * 0.02,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 400),
                        pageBuilder: (_, __, ___) => AffrimProcess(
                          s_name,
                        ),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Text("Visit Mirror"))
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _saveNameToStorage(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    setState(() {});
  }
}
