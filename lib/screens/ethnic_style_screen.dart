import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/face_ai_service.dart';
import 'ethnic_style_result_screen.dart';

class EthnicStyleScreen extends StatefulWidget {
  const EthnicStyleScreen({super.key});

  @override
  State<EthnicStyleScreen> createState() => _EthnicStyleScreenState();
}

class _EthnicStyleScreenState extends State<EthnicStyleScreen> {
  String? _userPhotoPath;
  String? _selectedGender;
  String? _selectedStyle;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Etnik stil seçenekleri
  final Map<String, Map<String, String>> _ethnicStyles = {
    'African': {
      'title': 'Traditional African Attire',
      'description': 'Experience yourself in vibrant traditional African clothing, featuring colorful patterns, fabrics like kente cloth, and authentic accessories.'
    },
    'Indian': {
      'title': 'Traditional Indian Attire',
      'description': 'See yourself in elegant sarees, lehengas, or kurta pajamas with intricate embroidery, vibrant colors, and traditional Indian jewelry.'
    },
    'Japanese': {
      'title': 'Traditional Japanese Attire',
      'description': 'Transform your look with a classic kimono, obi sash, and traditional Japanese footwear in an authentic setting.'
    },
    'Middle Eastern': {
      'title': 'Traditional Middle Eastern Attire',
      'description': 'Experience wearing traditional Middle Eastern clothing like thobes, abayas, or kaftans with intricate embroidery and patterns.'
    },
    'Native American': {
      'title': 'Traditional Native American Attire',
      'description': 'See yourself in traditional Native American regalia with intricate beadwork, feathers, and symbolic patterns honoring indigenous heritage.'
    },
    'Nordic': {
      'title': 'Traditional Nordic Attire',
      'description': 'Try on traditional Nordic folk costumes with embroidered patterns, unique headpieces, and authentic accessories from Scandinavian culture.'
    },
    'South American': {
      'title': 'Traditional South American Attire',
      'description': 'Transform your look with colorful ponchos, embroidered blouses, or traditional South American ceremonial clothing with vibrant patterns.'
    },
    'Thai': {
      'title': 'Traditional Thai Attire',
      'description': 'See yourself in elegant Thai silk garments, traditional sabai wraps, or formal Thai ceremonial clothing with gold accents.'
    },
  };

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 90,
    );

    if (image != null) {
      setState(() {
        _userPhotoPath = image.path;
      });
    }
  }

  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 90,
    );

    if (photo != null) {
      setState(() {
        _userPhotoPath = photo.path;
      });
    }
  }

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  void _selectStyle(String style) {
    setState(() {
      _selectedStyle = style;
    });
  }

  Future<void> _generateEthnicStyle() async {
    if (_userPhotoPath == null || _selectedStyle == null || _selectedGender == null) {
      _showErrorDialog('Please select a photo, your gender, and an ethnic style to continue.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final faceAiService = FaceAIService();
      final resultImagePath = await faceAiService.generateEthnicStyle(
        _userPhotoPath!,
        _selectedGender!,
        _selectedStyle!,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EthnicStyleResultScreen(
            userPhotoPath: _userPhotoPath!,
            resultImagePath: resultImagePath,
            style: _selectedStyle!,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('An error occurred while generating your ethnic style: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSelector() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 1: Upload Your Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose a clear, front-facing photo of yourself for the best results.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            if (_userPhotoPath != null)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: FileImage(File(_userPhotoPath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 2: Select Your Gender',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This helps us generate appropriate ethnic clothing styles.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectGender('female'),
                    child: Card(
                      color: _selectedGender == 'female'
                          ? Colors.pink.shade100
                          : Colors.white,
                      elevation: _selectedGender == 'female' ? 4 : 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.female,
                              size: 40,
                              color: _selectedGender == 'female'
                                  ? Colors.pink
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            const Text('Female'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectGender('male'),
                    child: Card(
                      color: _selectedGender == 'male'
                          ? Colors.blue.shade100
                          : Colors.white,
                      elevation: _selectedGender == 'male' ? 4 : 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.male,
                              size: 40,
                              color: _selectedGender == 'male'
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            const Text('Male'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleSelector() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 3: Choose an Ethnic Style',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Explore traditional clothing from around the world.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _ethnicStyles.length,
              itemBuilder: (context, index) {
                final style = _ethnicStyles.keys.elementAt(index);
                return GestureDetector(
                  onTap: () => _selectStyle(style),
                  child: Card(
                    elevation: _selectedStyle == style ? 4 : 1,
                    color: _selectedStyle == style
                        ? Colors.purple.shade50
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: _selectedStyle == style
                            ? Colors.purple
                            : Colors.grey.shade300,
                        width: _selectedStyle == style ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.public,
                            size: 32,
                            color: _selectedStyle == style
                                ? Colors.purple
                                : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            style,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: _selectedStyle == style
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ethnic Style Transformation'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Creating your ethnic style transformation...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explore Cultural Styles From Around the World',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Upload your photo and see yourself transformed in traditional ethnic clothing from different cultures.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildPhotoSelector(),
                    _buildGenderSelector(),
                    _buildStyleSelector(),
                    
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _userPhotoPath != null &&
                                _selectedGender != null &&
                                _selectedStyle != null
                            ? _generateEthnicStyle
                            : null,
                        icon: const Icon(Icons.api),
                        label: const Text(
                          'Generate My Ethnic Style',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Note: This feature is for entertainment purposes only. We respect all cultures and traditions.',
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