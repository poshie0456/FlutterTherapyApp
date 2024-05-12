// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class TTSService {
  final String apiKey;

  TTSService(this.apiKey);

  Future<void> speak(String text, String voice) async {
    final url = Uri.parse('https://api.openai.com/v1/audio/speech');
    final body = jsonEncode({
      "model": "tts-1",
      "input": text,
      "voice": voice,
    });

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        await createSpeechFile(); // Ensure the file exists
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/speech.mp3');

        await file.writeAsBytes(response.bodyBytes);
        await playAudio(file.path);
      } else {
        throw Exception(
            'Error converting text to speech: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      // Handle network errors
      print('Network error: $e');
    } on http.ClientException catch (e) {
      // Handle other HTTP client errors
      print('HTTP client error: $e');
    } catch (e) {
      // Handle unexpected errors
      print('Error: $e');
    }
  }

  Future<void> createSpeechFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/speech.mp3');
    if (!await file.exists()) {
      await file.create();
    }
  }

  Future<void> playAudio(String filePath) async {
    final file = File(filePath);
    final directory = await getApplicationDocumentsDirectory();
    if (await file.exists()) {
      final player = AudioPlayer();
      await player.play(DeviceFileSource('${directory.path}/speech.mp3'));
    } else {
      print('File not found: $filePath');
    }
  }
}
