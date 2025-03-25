import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class EthnicStyleResultScreen extends StatelessWidget {
  final String userPhotoPath;
  final String resultImagePath;
  final String style;

  const EthnicStyleResultScreen({
    super.key,
    required this.userPhotoPath,
    required this.resultImagePath,
    required this.style,
  });

  Future<void> _saveImage(BuildContext context) async {
    try {
      // İzin kontrolü
      final status = await Permission.storage.request();
      if (status.isGranted) {
        // Dosya oluştur
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage directory not found')),
          );
          return;
        }

        // Dosya adı oluştur
        final fileName = 'ethnic_style_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = '${directory.path}/$fileName';

        // Dosyayı kopyala
        final File originalFile = File(resultImagePath);
        await originalFile.copy(filePath);
        
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved successfully')),
        );
      } else {
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      print('Save error: $e');
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
      );
    }
  }

  Future<void> _shareImage() async {
    try {
      final xFile = XFile(resultImagePath);
      await Share.shareXFiles(
        [xFile],
        text: 'Check out my transformation into $style traditional clothing!',
      );
    } catch (e) {
      print('Share error: $e');
    }
  }

  Map<String, String> _getStyleDescription(String style) {
    Map<String, Map<String, String>> descriptions = {
      'African': {
        'title': 'Traditional African Attire',
        'description': 'The traditional clothing of Africa reflects the rich cultural diversity of the continent. Featuring vibrant colors, intricate patterns, and symbolic designs, these garments often tell stories about the wearer\'s heritage, status, and community. Common elements include kente cloth from Ghana, Ankara fabric popular across West Africa, and beaded accessories.'
      },
      'Indian': {
        'title': 'Traditional Indian Attire',
        'description': 'Indian traditional clothing encompasses a variety of regional styles. For women, the saree is an iconic garment made from a single piece of fabric draped elegantly around the body, while men often wear kurta pajamas. Both feature intricate embroidery, rich fabrics like silk, and are often adorned with gold embellishments for special occasions.'
      },
      'Japanese': {
        'title': 'Traditional Japanese Attire',
        'description': 'The kimono is Japan\'s most recognized traditional garment, characterized by its T-shaped, straight-lined robes that fall to the ankles. Kimonos are wrapped around the body with the left side over the right and secured with an obi sash. They come in various colors and patterns that indicate the wearer\'s age, gender, and the formality of the occasion.'
      },
      'Middle Eastern': {
        'title': 'Traditional Middle Eastern Attire',
        'description': 'Middle Eastern traditional clothing is designed for both modesty and adaptation to the climate. Common garments include the thobe (a long robe) for men and the abaya (a loose over-garment) for women. These are often complemented with headdresses like the keffiyeh for men or hijab for women, and feature intricate embroidery and patterns.'
      },
      'Native American': {
        'title': 'Traditional Native American Attire',
        'description': 'Native American traditional clothing varies widely among tribes but often includes buckskin garments, moccasins, and items decorated with beadwork, quillwork, and fringe. Ceremonial regalia may feature feathers, animal skins, and symbolic colors and patterns that hold spiritual and cultural significance to the specific tribe.'
      },
      'Nordic': {
        'title': 'Traditional Nordic Attire',
        'description': 'The traditional costumes of Nordic countries (called bunad in Norway, folkdräkt in Sweden) feature wool embroidered garments with regional variations in design, color, and accessories. These outfits often include vests, caps or bonnets, and white shirts with intricate embroidery that tells the story of the wearer\'s geographical origin.'
      },
      'South American': {
        'title': 'Traditional South American Attire',
        'description': 'South American traditional clothing is known for its vibrant colors and patterns, reflecting indigenous heritage blended with colonial influences. Common elements include the poncho, a rectangular garment with a hole in the middle for the head, and colorful woven textiles featuring geometric patterns and natural dyes.'
      },
      'Thai': {
        'title': 'Traditional Thai Attire',
        'description': 'Thai traditional clothing includes the chut thai for women, which consists of a pha nung (wrapped skirt) and a sabai (shawl) or fitted blouse. Men wear the chong kraben (wrapped lower garment) with a fitted shirt. These garments are often made from silk with gold thread embroidery and are complemented by elaborate jewelry and headdresses for formal occasions.'
      },
    };

    return {
      'title': descriptions[style]?['title'] ?? 'Traditional $style Attire',
      'description': descriptions[style]?['description'] ?? 'This traditional attire reflects the cultural heritage and customs of $style culture.'
    };
  }

  @override
  Widget build(BuildContext context) {
    final styleInfo = _getStyleDescription(style);

    return Scaffold(
      appBar: AppBar(
        title: Text(styleInfo['title'] ?? 'Ethnic Style'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sonuç gösterimi
              const Text(
                'Your Ethnic Style Transformation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Original and transformed images side by side
              Row(
                children: [
                  // Original image
                  Expanded(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                            child: Image.file(
                              File(userPhotoPath),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Original',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Transformed image
                  Expanded(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                            child: Image.file(
                              File(resultImagePath),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Transformed',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Style description
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        styleInfo['title'] ?? 'About This Style',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        styleInfo['description'] ?? 'No description available.',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _saveImage(context),
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _shareImage,
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Try another style button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Another Style'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Disclaimer
              const Text(
                'Note: This feature is for entertainment purposes only. We respect all cultures and traditions.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 