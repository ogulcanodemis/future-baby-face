import 'package:flutter/material.dart';
import '../components/image_picker_button.dart';
import '../services/storage_service.dart';
import '../services/face_ai_service.dart';
import '../components/photo_tips_dialog.dart';
import 'package:baby_face_ai/views/result_screen.dart';
import 'ethnic_style_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _parent1ImagePath;
  String? _parent2ImagePath;
  bool _isLoading = false;
  final StorageService _storageService = StorageService();
  final FaceAIService _faceAIService = FaceAIService();

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  Future<void> _loadSavedImages() async {
    final parent1Path = await _storageService.getParent1Image();
    final parent2Path = await _storageService.getParent2Image();
    
    setState(() {
      _parent1ImagePath = parent1Path;
      _parent2ImagePath = parent2Path;
    });
  }

  Future<void> _onParent1ImageSelected(String path) async {
    await _storageService.saveParent1Image(path);
    setState(() {
      _parent1ImagePath = path;
    });
  }

  Future<void> _onParent2ImageSelected(String path) async {
    await _storageService.saveParent2Image(path);
    setState(() {
      _parent2ImagePath = path;
    });
  }

  // Fotoğraf yükleme ipuçlarını göster
  void _showPhotoTips() {
    showDialog(
      context: context,
      builder: (context) => const PhotoTipsDialog(),
    );
  }

  // Etnik Stil ekranına git
  void _navigateToEthnicStyle() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EthnicStyleScreen(),
      ),
    );
  }

  Future<void> _analyzeFaces() async {
    if (_parent1ImagePath == null || _parent2ImagePath == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: const Text('Please upload both parent photos first.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final faceAiService = FaceAIService();
      final babyResult = await faceAiService.predictBabyFace(
        _parent1ImagePath!,
        _parent2ImagePath!,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            parent1Path: _parent1ImagePath!,
            parent2Path: _parent2ImagePath!,
            girlBabyPath: babyResult.girlImagePath,
            boyBabyPath: babyResult.boyImagePath,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred while creating baby face: $e'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Face Prediction'),
        centerTitle: true,
        actions: [
          // AppBar'a yardım butonu ekle
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Photo Guidelines',
            onPressed: _showPhotoTips,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Predicting your baby\'s face...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Discover Your Future Baby\'s Face!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select photos of both parents and see what your possible baby might look like with the help of AI.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    // Fotoğraf seçimi için yönergeler
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Photo Selection Guidelines',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'For best results, please select photos that are:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Clear, well-lit facial photos'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Front-facing without sunglasses or hats'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Recent photos with neutral expression'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Avoid group photos, filters, or edited images'),
                              ),
                            ],
                          ),
                          // Daha fazla yardım için buton
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _showPhotoTips,
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('More Tips'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ImagePickerButton(
                          onImageSelected: _onParent1ImageSelected,
                          currentImagePath: _parent1ImagePath,
                          buttonText: 'Mother\'s Photo',
                        ),
                        ImagePickerButton(
                          onImageSelected: _onParent2ImageSelected,
                          currentImagePath: _parent2ImagePath,
                          buttonText: 'Father\'s Photo',
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: _parent1ImagePath != null && _parent2ImagePath != null
                          ? _analyzeFaces
                          : null,
                      icon: const Icon(Icons.baby_changing_station),
                      label: const Text(
                        'Show My Baby',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 10),
                    
                    // Etnik Stil Özelliği
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.style, color: Colors.purple, size: 24),
                                SizedBox(width: 10),
                                Text(
                                  'Try Our New Feature!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'See yourself in traditional ethnic clothing from around the world. Upload a photo and choose from various cultural styles!',
                              style: TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 15),
                            OutlinedButton.icon(
                              onPressed: _navigateToEthnicStyle,
                              icon: const Icon(Icons.explore),
                              label: const Text('Explore Ethnic Styles'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.purple,
                                side: const BorderSide(color: Colors.purple),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Note: This app is for entertainment purposes only and does not guarantee scientific accuracy.',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 