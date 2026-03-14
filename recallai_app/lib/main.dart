import 'package:flutter/material.dart';
import 'voice_assistant.dart';
import 'api_service.dart';
import 'camera_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Recall AI",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RecallHome(),
    );
  }
}

class RecallHome extends StatefulWidget {
  const RecallHome({super.key});

  @override
  State<RecallHome> createState() => _RecallHomeState();
}

class _RecallHomeState extends State<RecallHome> {

  final VoiceService voice = VoiceService();
  final ApiService api = ApiService();
  final CameraService camera = CameraService();

  String text = "Press mic and say 'Hey Recall'";
  bool listening = false;

  Future<void> listen() async {

    setState(() {
      listening = true;
      text = "Listening...";
    });

    try {

      String speech = await voice.listen();

      if (speech.isEmpty) {

        setState(() {
          text = "I couldn't hear anything.";
          listening = false;
        });

        return;
      }

      setState(() {
        text = "You said: $speech";
      });

      /// Example camera trigger (future feature)
      if (speech.toLowerCase().contains("take picture")) {

        String? imagePath = await camera.takePicture();

        if (imagePath != null) {

          setState(() {
            text = "Picture captured!";
          });

          await voice.speak("Picture captured");

        } else {

          setState(() {
            text = "Camera cancelled.";
          });

        }

        listening = false;
        return;
      }

      /// Send voice command to backend
      String response = await api.sendCommand(speech);

      await voice.speak(response);

      setState(() {
        text = response;
      });

    } catch (e) {

      setState(() {
        text = "Error: $e";
      });

    }

    setState(() {
      listening = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Recall AI"),
        centerTitle: true,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.memory,
                size: 100,
                color: Colors.blue,
              ),

              const SizedBox(height: 30),

              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: listening ? null : listen,
                icon: const Icon(Icons.mic),
                label: Text(
                  listening ? "Listening..." : "Speak",
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}