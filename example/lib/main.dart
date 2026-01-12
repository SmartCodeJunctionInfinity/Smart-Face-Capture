import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_face_capture/smart_face_capture.dart';

void main() {
  runApp(const MyApp());
}

/// Example app demonstrating the Smart Face Capture package.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Face Capture Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// Home screen with button to start face capture.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Face Capture Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Tap the button below to start the guided face capture process.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FaceCaptureScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start Face Capture'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen that shows the face capture view.
class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({super.key});

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartFaceCaptureView(
        // Optional: Add custom captures
        customCaptures: const [
          CustomCaptureRequest(
            id: 'smile',
            label: 'Smile',
            instructionText: 'Please smile for the camera',
          ),
          CustomCaptureRequest(
            id: 'id_card',
            label: 'ID Card',
            instructionText: 'Hold your ID card next to your face',
          ),
        ],
        // Initial camera direction (front camera)
        initialCamera: CameraLensDirection.front,
        // Callback when all captures are completed
        onCompleted: (capturedFiles) {
          // Navigate to results screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                capturedFiles: capturedFiles,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Screen displaying the captured images.
class ResultsScreen extends StatelessWidget {
  final List<XFile> capturedFiles;

  const ResultsScreen({
    super.key,
    required this.capturedFiles,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Images'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: capturedFiles.length,
        itemBuilder: (context, index) {
          final labels = [
            'Front Face',
            'Left Face',
            'Right Face',
            'Smile',
            'ID Card',
          ];
          final label = index < labels.length ? labels[index] : 'Image ${index + 1}';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Image.file(
                  File(capturedFiles[index].path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 64),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Path: ${capturedFiles[index].path}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (route) => false,
          );
        },
        icon: const Icon(Icons.home),
        label: const Text('Back to Home'),
      ),
    );
  }
}
