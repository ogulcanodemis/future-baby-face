import 'package:flutter/material.dart';

class EthnicStyle {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String promptTemplate;
  final Color accentColor;

  const EthnicStyle({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.promptTemplate,
    required this.accentColor,
  });

  // Önceden tanımlanmış etnik stil listesi
  static List<EthnicStyle> getAllStyles() {
    return [
      const EthnicStyle(
        id: 'turkish',
        name: 'Turkish',
        description: 'Traditional Turkish clothing with rich embroidery and vibrant colors',
        imagePath: 'assets/images/turkish_style.png', // Placeholder, assetler henüz eklenmedi
        promptTemplate: 'photorealistic portrait of the person, wearing traditional Turkish clothing, {gender} outfit with rich embroidery, cultural Turkish attire, professional studio lighting, high detail, 8k resolution, sharp focus',
        accentColor: Color(0xFFCE1126), // Türk bayrağı kırmızısı
      ),
      const EthnicStyle(
        id: 'indian',
        name: 'Indian',
        description: 'Colorful traditional Indian clothing with intricate patterns',
        imagePath: 'assets/images/indian_style.png', // Placeholder
        promptTemplate: 'photorealistic portrait of the person, wearing traditional Indian {gender} clothing, with intricate patterns and vibrant colors, cultural Indian attire, professional studio lighting, high detail, 8k resolution, sharp focus',
        accentColor: Color(0xFFFF9933), // Hint bayrağı turuncu
      ),
      const EthnicStyle(
        id: 'japanese',
        name: 'Japanese',
        description: 'Traditional Japanese kimono with elegant patterns',
        imagePath: 'assets/images/japanese_style.png', // Placeholder
        promptTemplate: 'photorealistic portrait of the person, wearing traditional Japanese kimono, elegant {gender} outfit, cultural Japanese attire, professional studio lighting, high detail, 8k resolution, sharp focus',
        accentColor: Color(0xFFBC002D), // Japon bayrağı kırmızısı
      ),
      const EthnicStyle(
        id: 'african',
        name: 'African',
        description: 'Vibrant African patterns and traditional clothing',
        imagePath: 'assets/images/african_style.png', // Placeholder
        promptTemplate: 'photorealistic portrait of the person, wearing traditional African clothing with vibrant patterns, {gender} outfit, cultural African attire, professional studio lighting, high detail, 8k resolution, sharp focus',
        accentColor: Color(0xFF078930), // Pan-Afrika yeşili
      ),
      const EthnicStyle(
        id: 'arabic',
        name: 'Arabic',
        description: 'Elegant Arabian traditional clothing with intricate details',
        imagePath: 'assets/images/arabic_style.png', // Placeholder 
        promptTemplate: 'photorealistic portrait of the person, wearing traditional Arabic {gender} clothing, elegant outfit with intricate details, cultural Arabian attire, professional studio lighting, high detail, 8k resolution, sharp focus',
        accentColor: Color(0xFF006C35), // Arap yeşili
      ),
      const EthnicStyle(
        id: 'mexican',
        name: 'Mexican',
        description: 'Colorful traditional Mexican clothing with festive patterns',
        imagePath: 'assets/images/mexican_style.png', // Placeholder
        promptTemplate: 'photorealistic portrait of the person, wearing traditional Mexican {gender} clothing, colorful outfit with festive patterns, cultural Mexican attire, professional studio lighting, high detail, 8k resolution, sharp focus',
        accentColor: Color(0xFF006847), // Meksika bayrağı yeşili
      ),
      const EthnicStyle(
        id: 'russian',
        name: 'Russian',
        description: 'Traditional Russian attire with ornate details',
        imagePath: 'assets/images/russian_style.png', // Placeholder
        promptTemplate: 'photorealistic portrait of the person, wearing traditional Russian {gender} clothing, ornate details, cultural Russian attire, professional studio lighting, high detail, 8k resolution, sharp focus',
        accentColor: Color(0xFFD52B1E), // Rus bayrağı kırmızısı
      ),
      const EthnicStyle(
        id: 'viking',
        name: 'Viking',
        description: 'Historic Norse/Viking attire with leather and fur elements',
        imagePath: 'assets/images/viking_style.png', // Placeholder
        promptTemplate: 'photorealistic portrait of the person, as a Viking, wearing traditional Norse clothing with leather and fur elements, {gender} outfit, historic Viking attire, professional studio lighting, high detail, 8k resolution, sharp focus',
        accentColor: Color(0xFF002868), // İskandinav mavi
      ),
    ];
  }

  // ID'ye göre stil bulma
  static EthnicStyle? getStyleById(String id) {
    try {
      return getAllStyles().firstWhere((style) => style.id == id);
    } catch (e) {
      return null;
    }
  }
} 