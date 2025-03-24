import 'dart:io';
import 'package:baby_face_ai/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:baby_face_ai/services/face_ai_service.dart';

class ResultScreen extends StatelessWidget {
  final String parent1Path;
  final String parent2Path;
  final String girlBabyPath;
  final String boyBabyPath;

  const ResultScreen({
    Key? key,
    required this.parent1Path,
    required this.parent2Path,
    required this.girlBabyPath,
    required this.boyBabyPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Prediction Result'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Meet Your Family\'s New Members!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Ebeveyn resimleri
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Mother', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(parent1Path),
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Father', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(parent2Path),
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              const Divider(thickness: 1),
              const SizedBox(height: 20),
              
              // Bebek resimleri - Hem kız hem erkek
              const Text(
                'Baby Prediction Results',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Bebekler yan yana
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Kız Bebek
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Baby Girl',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: girlBabyPath.startsWith('assets')
                                ? Image.asset(
                                    girlBabyPath,
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(girlBabyPath),
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.cover,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Erkek Bebek
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Baby Boy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: boyBabyPath.startsWith('assets')
                                ? Image.asset(
                                    boyBabyPath,
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(boyBabyPath),
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.cover,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Bilgilendirme notu
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Note: These images are created using artificial intelligence technologies and are for entertainment purposes only. Real genetic inheritance depends on much more complex factors.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Yeniden denemek için buton
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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