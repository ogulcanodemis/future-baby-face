import 'dart:io';
import 'package:flutter/material.dart';

class ResultDisplay extends StatelessWidget {
  final String imagePath;
  final VoidCallback onSavePressed;
  final VoidCallback onSharePressed;
  final VoidCallback onTryAgainPressed;

  const ResultDisplay({
    super.key,
    required this.imagePath,
    required this.onSavePressed,
    required this.onSharePressed,
    required this.onTryAgainPressed,
  });

  @override
  Widget build(BuildContext context) {
    bool isAssetImage = !imagePath.startsWith('/');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Congratulations! Here\'s your baby:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: isAssetImage
                ? Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: onSavePressed,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: onSharePressed,
              icon: const Icon(Icons.share),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: onTryAgainPressed,
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
        ),
      ],
    );
  }
} 