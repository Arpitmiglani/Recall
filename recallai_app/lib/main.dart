import 'package:flutter/material.dart';
import 'voice_assistant.dart';
import 'api_service.dart';
import 'camera_service.dart';
import 'recall_logo.dart';

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
        primaryColor: const Color(0xFF3A7AFE),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3A7AFE),
          elevation: 0,
          centerTitle: true,
        ),
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

    if (listening) return;

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

        setState(() {
          listening = false;
        });

        return;
      }

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
      ),

      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_img.jpeg"),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const RecallLogo(),

                const SizedBox(height: 25),

                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // 👈 TEXT WHITE KAR DIYA
                  ),
                ),

                const SizedBox(height: 40),

                GestureDetector(
                  onTap: listening ? null : listen,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: listening ? Colors.red : const Color(0xFF3A7AFE),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  listening
                      ? "Listening..."
                      : "Tap the mic and speak your reminder",
                  style: const TextStyle(color: Colors.grey),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}