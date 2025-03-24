import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../components/result_display.dart';

class ResultScreen extends StatelessWidget {
  final String babyImagePath;

  const ResultScreen({super.key, required this.babyImagePath});

  Future<void> _saveImage(BuildContext context) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage access failed')),
        );
        return;
      }

      final newPath = '${directory.path}/baby_face_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(babyImagePath).copy(newPath);

      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved: $newPath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save image: $e')),
      );
    }
  }

  void _shareImage(BuildContext context) {
    // Note: 'share_plus' package can be used for real sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing feature not yet implemented')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Baby\'s Face'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ResultDisplay(
              imagePath: babyImagePath,
              onSavePressed: () => _saveImage(context),
              onSharePressed: () => _shareImage(context),
              onTryAgainPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }
} 