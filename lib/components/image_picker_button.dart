import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'photo_tips_dialog.dart';

class ImagePickerButton extends StatelessWidget {
  final Function(String) onImageSelected;
  final String? currentImagePath;
  final String buttonText;
  final IconData icon;

  const ImagePickerButton({
    super.key, 
    required this.onImageSelected,
    this.currentImagePath,
    required this.buttonText,
    this.icon = Icons.add_a_photo,
  });

  // Fotoğraf seçim yönergelerini gösteren dialog
  Future<void> _showPhotoGuidelines(BuildContext context) async {
    // Ekran boyutunu alalım
    final screenSize = MediaQuery.of(context).size;
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Photo Guidelines', style: TextStyle(fontWeight: FontWeight.bold)),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenSize.height * 0.5, // Ekran yüksekliğinin %50'si
              maxWidth: screenSize.width * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGuidelineItem(
                    Icons.face, 
                    'Face Clearly Visible',
                    'Choose a photo where the face is clearly visible and well-lit.'
                  ),
                  const SizedBox(height: 12),
                  _buildGuidelineItem(
                    Icons.wb_sunny, 
                    'Good Lighting',
                    'Photo should be taken in good lighting conditions - avoid dark or overly bright images.'
                  ),
                  const SizedBox(height: 12),
                  _buildGuidelineItem(
                    Icons.portrait, 
                    'Frontal Face Position',
                    'Face should be looking directly at the camera - avoid profiles or angled views.'
                  ),
                  const SizedBox(height: 12),
                  _buildGuidelineItem(
                    Icons.filter, 
                    'No Filters',
                    'Do not use photos with filters, stickers, or digital enhancements.'
                  ),
                  const SizedBox(height: 12),
                  _buildGuidelineItem(
                    Icons.center_focus_strong, 
                    'Close Up',
                    'Choose a close-up photo where your face fills most of the frame.'
                  ),
                  const SizedBox(height: 12),
                  _buildGuidelineItem(
                    Icons.photo_size_select_actual, 
                    'Recent Photo',
                    'Use a recent photo for most accurate results.'
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Continue to Photo Selection'),
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromGallery(context);
              },
            ),
          ],
        );
      },
    );
  }
  
  // Daha detaylı fotoğraf ipuçları
  void _showDetailedPhotoTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PhotoTipsDialog(),
    );
  }
  
  // Her bir yönerge maddesi için widget
  Widget _buildGuidelineItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Galeriden fotoğraf seçme işlemi
  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90, // Yüksek kalite
      );
      
      if (image != null) {
        onImageSelected(image.path);
      }
    } catch (e) {
      // Hata durumunda kullanıcıya göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while selecting image: $e')),
      );
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    // Önce yönergeleri göster, sonra fotoğraf seçimine devam et
    _showPhotoGuidelines(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 5),
            // Yardım butonu
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.blue, size: 20),
              onPressed: () => _showDetailedPhotoTips(context),
              tooltip: 'Get tips for better photos',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(context),
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: currentImagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.file(
                      File(currentImagePath!),
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to select',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'a photo',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
} 