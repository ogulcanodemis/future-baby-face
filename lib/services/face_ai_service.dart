import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class BabyResult {
  final String girlImagePath;
  final String boyImagePath;

  BabyResult({required this.girlImagePath, required this.boyImagePath});
}

class ParentFeatures {
  final Color? hairColor;
  final Color? eyeColor;
  final String skinTone;
  final bool hasFreckles;
  final bool hasDimples;

  ParentFeatures({
    this.hairColor,
    this.eyeColor,
    this.skinTone = 'medium',
    this.hasFreckles = false,
    this.hasDimples = false,
  });
}

class FaceAIService {
  // Yüksek kaliteli, gerçekçi bir görsel modeli kullanalım
  static const String apiUrl = 'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0';
  
  // İki ebeveyn fotoğrafından çocuk yüzü tahmin eden metod
  // Hem kız hem erkek bebek döndürüyoruz
  Future<BabyResult> predictBabyFace(String parent1Path, String parent2Path) async {
    try {
      // API anahtarını .env dosyasından oku
      final apiKey = dotenv.env['HF_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        throw Exception('API anahtarı bulunamadı. Lütfen .env dosyasını kontrol edin.');
      }
      
      print('API anahtarını başarıyla aldık, ebeveyn resimlerini analiz ediyoruz...');
      
      // Fotoğrafları yükle
      final parent1File = File(parent1Path);
      final parent2File = File(parent2Path);
      
      if (!await parent1File.exists() || !await parent2File.exists()) {
        throw Exception('Ebeveyn fotoğrafları bulunamadı.');
      }
      
      print('Ebeveyn fotoğrafları bulundu, özellikleri analiz ediliyor...');
      
      // Ebeveyn fotoğraflarından özellikler çıkarıyoruz
      final parentFeatures = await _analyzeParentPhotos(parent1Path, parent2Path);
      
      // Hem kız hem erkek bebek üretiyoruz
      print('Her iki cinsiyette bebek oluşturuluyor...');
      
      // Kız bebek üret
      final girlBabyPath = await _generateBaby(apiKey, true, parentFeatures);
      
      // Erkek bebek üret
      final boyBabyPath = await _generateBaby(apiKey, false, parentFeatures);
      
      // İki bebeği birden döndür
      return BabyResult(
        girlImagePath: girlBabyPath,
        boyImagePath: boyBabyPath,
      );
    } catch (e) {
      print('Genel hata: $e');
      
      // Hata durumunda dummy resimleri döndür
      return BabyResult(
        girlImagePath: 'assets/images/dummy_baby.png',
        boyImagePath: 'assets/images/dummy_baby.png',
      );
    }
  }
  
  // Ebeveyn fotoğraflarını analiz et ve özelliklerini çıkar
  Future<ParentFeatures> _analyzeParentPhotos(String parent1Path, String parent2Path) async {
    try {
      final parent1File = File(parent1Path);
      final parent2File = File(parent2Path);
      
      final parent1Bytes = await parent1File.readAsBytes();
      final parent2Bytes = await parent2File.readAsBytes();
      
      // Resimleri image paketi ile decode et
      final parent1Image = img.decodeImage(parent1Bytes);
      final parent2Image = img.decodeImage(parent2Bytes);
      
      if (parent1Image == null || parent2Image == null) {
        return ParentFeatures();
      }
      
      // Basit renk analizi - yüzün orta bölgesindeki renkleri alıyoruz
      // Bu basitleştirilmiş bir yaklaşım
      
      // Anne için dominant renkleri analiz et
      final parent1Colors = _extractDominantColors(parent1Image);
      final parent1HairColor = parent1Colors.isNotEmpty ? parent1Colors[0] : null;
      final parent1EyeColor = parent1Colors.length > 1 ? parent1Colors[1] : null;
      
      // Baba için dominant renkleri analiz et
      final parent2Colors = _extractDominantColors(parent2Image);
      final parent2HairColor = parent2Colors.isNotEmpty ? parent2Colors[0] : null;
      final parent2EyeColor = parent2Colors.length > 1 ? parent2Colors[1] : null;
      
      // Ebeveyn özelliklerini birleştir - burada rastgele birini seçiyoruz
      // Gerçek genetik daha karmaşık, bu sadece bir örnek
      final random = math.Random();
      final hairColor = random.nextBool() ? parent1HairColor : parent2HairColor;
      final eyeColor = random.nextBool() ? parent1EyeColor : parent2EyeColor;
      
      // Cilt tonu tahmini
      final skinTone = _estimateSkinTone(parent1Image, parent2Image);
      
      print('Ebeveyn özellikleri başarıyla analiz edildi');
      return ParentFeatures(
        hairColor: hairColor,
        eyeColor: eyeColor,
        skinTone: skinTone,
        hasFreckles: random.nextDouble() < 0.3, // %30 olasılık
        hasDimples: random.nextDouble() < 0.4,  // %40 olasılık
      );
    } catch (e) {
      print('Ebeveyn fotoğrafları analiz edilemedi: $e');
      // Hata durumunda varsayılan özellikler kullan
      return ParentFeatures();
    }
  }
  
  // Görüntüden baskın renkleri çıkar
  List<Color> _extractDominantColors(img.Image image) {
    try {
      Map<int, int> colorCounts = {};
      
      // Rastgele birkaç piksel seç ve analiz et
      final random = math.Random();
      for (int i = 0; i < 1000; i++) {
        final x = random.nextInt(image.width);
        final y = random.nextInt(image.height);
        
        // Yeni Pixel API'sı ile çalışırken artık direkt renk değerini alabiliriz
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        // RGB değerlerini tek bir renk koduna dönüştür
        final colorCode = (r << 16) | (g << 8) | b;
        
        if (colorCounts.containsKey(colorCode)) {
          colorCounts[colorCode] = colorCounts[colorCode]! + 1;
        } else {
          colorCounts[colorCode] = 1;
        }
      }
      
      // Sıklığa göre sırala
      final sortedColors = colorCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      // En yaygın renkleri Color nesnelerine dönüştür ve döndür
      return sortedColors.take(3).map((entry) {
        final colorValue = entry.key;
        return Color(colorValue | 0xFF000000); // Alpha değerini ekle
      }).toList();
    } catch (e) {
      print('Dominant renk analizi hatası: $e');
      return [];
    }
  }
  
  // Cilt tonu tahmini - Daha kesin ve doğru analiz yapabilmek için
  String _estimateSkinTone(img.Image? parent1Image, img.Image? parent2Image) {
    if (parent1Image == null || parent2Image == null) {
      return 'medium';
    }
    
    try {
      // Yüz bölgesi analizi için daha iyi bir yaklaşım
      // Resimlerin merkez bölgesinden örnekleme
      double parent1Brightness = _extractFaceBrightness(parent1Image);
      double parent2Brightness = _extractFaceBrightness(parent2Image);
      
      // İki ebeveynin cilt tonu ortalaması
      final avgBrightness = (parent1Brightness + parent2Brightness) / 2;
      
      print('Tespit edilen ortalama cilt tonu parlaklık değeri: $avgBrightness');
      
      // Parlaklık değerine göre cilt tonu sınıflandırması - eşik değerleri daha doğru ayarladık
      if (avgBrightness > 170) return 'fair';
      if (avgBrightness > 150) return 'light';
      if (avgBrightness > 130) return 'medium light';
      if (avgBrightness > 110) return 'medium';
      if (avgBrightness > 90) return 'medium tan';
      if (avgBrightness > 70) return 'tan';
      if (avgBrightness > 50) return 'medium dark';
      return 'dark';
      
    } catch (e) {
      print('Cilt tonu tahmini hatası: $e');
      return 'light'; // Varsayılan değer olarak 'light' kullan - beyaz tenli varsayalım
    }
  }
  
  // Bir yüz görüntüsünden cilt tonu parlaklığını çıkar
  double _extractFaceBrightness(img.Image image) {
    // Yüz genellikle görüntünün merkezinde olduğunu varsayalım
    // Daha gelişmiş uygulamalarda gerçek yüz tespiti yapılmalıdır
    
    final centerX = image.width ~/ 2;
    final centerY = image.height ~/ 3; // Yüz genelde üst 1/3'te
    final faceRadius = image.width ~/ 6; // Yüz boyutu tahmini
    
    List<double> brightnessSamples = [];
    
    // Yüz bölgesinden örnekler al
    for (int y = centerY - faceRadius; y < centerY + faceRadius; y += 5) { // Atlayarak örnekleme
      for (int x = centerX - faceRadius; x < centerX + faceRadius; x += 5) {
        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          // Merkeze olan uzaklığı hesapla (yuvarlak bölge içinde örnekleme)
          final distance = _distance(x, y, centerX, centerY);
          
          // Yüz bölgesi içindeyse (dairesel)
          if (distance <= faceRadius) {
            final pixel = image.getPixel(x, y);
            
            final r = pixel.r.toInt();
            final g = pixel.g.toInt();
            final b = pixel.b.toInt();
            
            // HSL renk uzayında dönüştürme - ten rengi tespiti için daha iyi
            final hsl = _rgbToHsl(r, g, b);
            final h = hsl[0];
            final s = hsl[1];
            final l = hsl[2];
            
            // Ten rengi hue (ton) aralığında mı kontrol et (yaklaşık 0-40 derece)
            if ((h >= 0 && h <= 40) && s < 0.6) { // Doygunluk düşük olmalı
              brightnessSamples.add(l * 255); // 0-255 aralığına dönüştür
            }
          }
        }
      }
    }
    
    // Ten rengi örneklerinin ortalamasını al
    if (brightnessSamples.isEmpty) {
      // Örnekler bulunamadıysa, genel ortalama parlaklık
      double totalBrightness = 0;
      int count = 0;
      
      for (int y = 0; y < image.height; y += 10) {
        for (int x = 0; x < image.width; x += 10) {
          final pixel = image.getPixel(x, y);
          final r = pixel.r.toInt();
          final g = pixel.g.toInt();
          final b = pixel.b.toInt();
          totalBrightness += (r + g + b) / 3;
          count++;
        }
      }
      
      return count > 0 ? totalBrightness / count : 150;
    }
    
    return brightnessSamples.reduce((a, b) => a + b) / brightnessSamples.length;
  }
  
  // İki nokta arasındaki mesafeyi hesapla
  double _distance(int x1, int y1, int x2, int y2) {
    return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
  }
  
  // RGB'yi HSL'ye dönüştürme (Ton, Doygunluk, Parlaklık)
  List<double> _rgbToHsl(int r, int g, int b) {
    final rf = r / 255;
    final gf = g / 255;
    final bf = b / 255;
    
    final max = [rf, gf, bf].reduce(math.max);
    final min = [rf, gf, bf].reduce(math.min);
    final delta = max - min;
    
    double h = 0; // Ton
    double s = 0; // Doygunluk
    final l = (max + min) / 2; // Parlaklık
    
    if (delta != 0) {
      s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min);
      
      if (max == rf) {
        h = (gf - bf) / delta + (gf < bf ? 6 : 0);
      } else if (max == gf) {
        h = (bf - rf) / delta + 2;
      } else {
        h = (rf - gf) / delta + 4;
      }
      
      h *= 60; // Dereceye dönüştür
    }
    
    return [h, s, l];
  }
  
  // Tek bir bebek üretme fonksiyonu
  Future<String> _generateBaby(String apiKey, bool isGirl, ParentFeatures features) async {
    // Prompt için özellikleri metin olarak dönüştür
    final String gender = isGirl ? "kız" : "erkek";
    print('$gender bebek üretiliyor...');
    
    // Saç rengi ve göz rengi HEX'ten okunabilir formata dönüştür
    final String hairColorText = _getColorDescription(features.hairColor);
    final String eyeColorText = _getColorDescription(features.eyeColor);
    
    // Ana modelle deneme
    try {
      return await _generateWithMainModel(apiKey, isGirl, features, hairColorText, eyeColorText);
    } catch (e) {
      print('Ana model hatası: $e, alternatif modele geçiliyor...');
      // Ana model başarısız olursa alternatif modeli dene
      try {
        return await _generateWithAlternativeModel(apiKey, isGirl, features, hairColorText, eyeColorText);
      } catch (e2) {
        print('Alternatif model hatası: $e2, yedek modele geçiliyor...');
        // Alternatif model de başarısız olursa yedek modeli dene
        try {
          return await _generateWithBackupModel(apiKey, isGirl, features, hairColorText, eyeColorText);
        } catch (e3) {
          print('Tüm modeller başarısız oldu: $e3');
          // Tüm modeller başarısız olursa dummy resim döndür
          return 'assets/images/dummy_baby.png';
        }
      }
    }
  }
  
  // Hex renk kodunu insanlar için okunabilir renk tanımlamasına dönüştür
  String _getColorDescription(Color? color) {
    if (color == null) return "natural";
    
    // Rengin RGB bileşenlerini al
    final int r = color.red;
    final int g = color.green;
    final int b = color.blue;
    
    // Açıklık/koyuluk tespiti
    final double brightness = (r * 299 + g * 587 + b * 114) / 1000;
    final String intensity = brightness > 170 ? "light" : (brightness < 85 ? "dark" : "medium");
    
    // Baskın renk tespiti
    if (r > g + b) return "${intensity} red";
    if (g > r + b) return "${intensity} green";
    if (b > r + g) return "${intensity} blue";
    if (r > b && g > b && (r - b > 50) && (g - b > 50)) return "${intensity} yellow";
    if (r > g && b > g && (r - g > 50) && (b - g > 50)) return "${intensity} purple";
    if (g > r && b > r && (g - r > 50) && (b - r > 50)) return "${intensity} cyan";
    if (r > 200 && g > 200 && b > 200) return "blonde";
    if (r < 50 && g < 50 && b < 50) return "black";
    if (r > 170 && g > 120 && b > 90) return "golden blonde";
    if (r > 110 && g > 65 && b > 50) return "brown";
    
    return "natural";
  }
  
  // Ana modelle bebek üretme
  Future<String> _generateWithMainModel(String apiKey, bool isGirl, ParentFeatures features, 
                                        String hairColorText, String eyeColorText) async {
    print('SDXL modeli ile bebek üretiliyor...');
    final gender = isGirl ? "baby girl" : "baby boy";
    final chairColor = isGirl ? "pink" : "blue";
    
    // Ultra gerçekçi profesyonel fotoğraf prompt'u
    final prompt = """
    ultra realistic portrait of a happy smiling $gender baby, (((${features.skinTone} skin tone, caucasian))),
    with $hairColorText hair and $eyeColorText eyes, exactly matching color,
    ${features.hasFreckles ? 'with subtle light freckles on cheeks, ' : ''}
    ${features.hasDimples ? 'with cute dimples when smiling, ' : ''}
    sitting upright on a small $chairColor wooden chair, 
    perfectly centered in frame, front facing pose, eye-level camera angle,
    bright delightful genuine smile showing baby teeth, 
    sparkling expressive innocent eyes with defined eyelashes,
    soft natural healthy skin with fine pores and realistic texture,
    crisp sharp professional photograph shot with Canon EOS R5 camera,
    85mm f/1.4 portrait lens at f/2.8 aperture,
    1/125 shutter speed, ISO 100, natural face proportions,
    professional studio lighting setup with key light, fill light and rim light,
    soft boxes for gentle shadows, beauty dish for facial details, 
    studio background with subtle gradient, perfect color grading,
    shallow depth of field with background bokeh, tack sharp focus on eyes,
    8K ultra HD resolution, photorealistic hyperdetailed, award winning photograph
    """;
    
    final negativePrompt = """
    cartoon, animation, anime, drawing, painting, sketch, illustration, 
    digital art, 3D render, CG, low quality, low resolution, bad anatomy, 
    black skin if not specified, incorrect skin tone, wrong eye color, 
    wrong hair color, deformed, distorted features, unnatural proportions, 
    blurry, grainy, noisy, dull, oversaturated, multiple babies, wrong age, 
    extra limbs, missing body parts, extra fingers, artificial look, plastic skin,
    flat lighting, awkward pose, unnatural smile, crooked eyes, asymmetrical face,
    adult features, creepy, scary, watermark, text, logo, stock photo look
    """;
    
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "inputs": prompt,
        "parameters": {
          "negative_prompt": negativePrompt,
          "num_inference_steps": 90,         // Daha fazla adım = daha detaylı sonuç
          "guidance_scale": 8.0,             // Prompt'a bağlılık (7-9 arası ideal)
          "width": 832,                      // Daha yüksek çözünürlük
          "height": 832,                     // Daha yüksek çözünürlük
          "seed": math.Random().nextInt(2147483647)
        }
      }),
    );
    
    print('SDXL API cevap kodu: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final resultBytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final babyImagePath = '${tempDir.path}/baby_${isGirl ? 'girl' : 'boy'}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await File(babyImagePath).writeAsBytes(resultBytes);
      print('${isGirl ? "Kız" : "Erkek"} bebek resmi oluşturuldu: $babyImagePath');
      return babyImagePath;
    } else {
      print('SDXL API Hata: ${response.statusCode} - ${response.body}');
      throw Exception('SDXL model hatası');
    }
  }
  
  // Alternatif modelle bebek üretme
  Future<String> _generateWithAlternativeModel(String apiKey, bool isGirl, ParentFeatures features, 
                                              String hairColorText, String eyeColorText) async {
    print('Realistic Vision modeli ile bebek üretiliyor...');
    final altModelUrl = 'https://api-inference.huggingface.co/models/SG161222/Realistic_Vision_V5.0';
    
    final gender = isGirl ? "baby girl" : "baby boy";
    final chairColor = isGirl ? "pink" : "blue";
    
    final prompt = """
    professional baby portrait, photorealistic, hyperdetailed, beautiful smiling $gender baby,
    (((${features.skinTone} skin tone, caucasian))), exactly matching color,
    with $hairColorText hair and $eyeColorText eyes,
    ${features.hasFreckles ? 'with subtle light freckles, ' : ''}
    ${features.hasDimples ? 'with cute dimples, ' : ''}
    sitting properly on a small $chairColor wooden chair, perfectly centered in frame,
    front-facing pose, happy genuine facial expression with natural smile showing baby teeth,
    shot with Nikon Z8 camera, 70-200mm f/2.8 lens at 135mm, f/4, 1/200s, ISO 200,
    professional studio lighting setup with 3-point lighting, soft reflection umbrella,
    crisp detailed skin texture, perfect focus on face, natural studio environment,
    8k ultra detailed, photographic, magazine quality, award-winning portrait
    """;
    
    final negativePrompt = """
    cartoon, animation, toy, doll, deformed, multiple faces, low quality,
    blurry, bad anatomy, extra limbs, missing limbs, black skin if not specified, 
    incorrect skin tone, wrong eye color, wrong hair color, 
    poorly rendered face, bad proportions, duplicate, morbid, unnatural pose,
    unnatural lighting, harsh shadows, artificial looking, digital art style,
    illustration style, painting style, oversaturated
    """;
    
    final response = await http.post(
      Uri.parse(altModelUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "inputs": prompt,
        "parameters": {
          "negative_prompt": negativePrompt,
          "num_inference_steps": 50,
          "guidance_scale": 8.0,
          "width": 768,
          "height": 768,
          "seed": math.Random().nextInt(2147483647)
        }
      }),
    );
    
    print('Realistic Vision API cevap kodu: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final resultBytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final babyImagePath = '${tempDir.path}/baby_${isGirl ? 'girl' : 'boy'}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await File(babyImagePath).writeAsBytes(resultBytes);
      print('Alternatif modelden ${isGirl ? "kız" : "erkek"} bebek resmi oluşturuldu');
      return babyImagePath;
    } else {
      print('Alternatif API Hata: ${response.statusCode} - ${response.body}');
      throw Exception('Alternatif model hatası');
    }
  }
  
  // Yedek modelle bebek üretme
  Future<String> _generateWithBackupModel(String apiKey, bool isGirl, ParentFeatures features, 
                                         String hairColorText, String eyeColorText) async {
    print('Yedek model ile bebek üretiliyor...');
    final backupUrl = 'https://api-inference.huggingface.co/models/runwayml/stable-diffusion-v1-5';
    
    final gender = isGirl ? "baby girl" : "baby boy";
    final chairColor = isGirl ? "pink" : "blue";
    
    final prompt = """
    professional studio portrait of a $gender baby with ${features.skinTone} skin tone, caucasian,
    $hairColorText hair and $eyeColorText eyes, smiling happily,
    sitting on a small $chairColor wooden chair, centered in frame,
    studio lighting, Canon 5D Mark IV, 50mm f/1.2 lens, crystal clear image,
    detailed skin texture, high-end magazine portrait, ultra-realistic, 
    photorealistic, 4k, professional family portrait photography
    """;
    
    final negativePrompt = """
    cartoon, doll, toy, blurry, multiple people, black skin if not specified,
    incorrect skin tone, wrong eye color, wrong hair color, deformed face,
    bad anatomy, poor lighting, oversaturated, low quality
    """;
    
    final response = await http.post(
      Uri.parse(backupUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "inputs": prompt,
        "parameters": {
          "negative_prompt": negativePrompt,
          "num_inference_steps": 45,       // Biraz arttırdık
          "guidance_scale": 7.5,
          "width": 512,                    // SD 1.5 için bu boyut daha iyi
          "height": 512,                   // SD 1.5 için bu boyut daha iyi
          "seed": math.Random().nextInt(2147483647)
        }
      }),
    );
    
    print('Yedek model API cevap kodu: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final resultBytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final babyImagePath = '${tempDir.path}/baby_${isGirl ? 'girl' : 'boy'}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await File(babyImagePath).writeAsBytes(resultBytes);
      print('Yedek modelden ${isGirl ? "kız" : "erkek"} bebek resmi oluşturuldu');
      return babyImagePath;
    } else {
      print('Yedek API Hata: ${response.statusCode} - ${response.body}');
      throw Exception('Yedek model hatası');
    }
  }

  // Etnik stil dönüşümü oluşturma metodu
  Future<String> generateEthnicStyle(String userPhotoPath, String gender, String ethnicStyle) async {
    try {
      // API anahtarını .env dosyasından oku
      final apiKey = dotenv.env['HF_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        throw Exception('API key not found. Please check the .env file.');
      }
      
      print('Generating ethnic style: $ethnicStyle for $gender');
      
      // Kullanıcının fiziksel özelliklerini analiz et
      Map<String, String> userFeatures = await _analyzeUserFeatures(userPhotoPath);
      
      print('Detected user features: $userFeatures');
      
      try {
        // Ana modelle dene
        return await _generateEthnicWithMainModel(apiKey, gender, ethnicStyle, userFeatures);
      } catch (mainModelError) {
        print('Main model error: $mainModelError, trying alternative model...');
        
        // Alternatif modelle dene
        try {
          return await _generateEthnicWithAlternativeModel(apiKey, gender, ethnicStyle, userFeatures);
        } catch (alternativeModelError) {
          print('Alternative model error: $alternativeModelError, trying backup model...');
          
          // Yedek modelle dene
          return await _generateEthnicWithBackupModel(apiKey, gender, ethnicStyle, userFeatures);
        }
      }
    } catch (e) {
      print('Error in generateEthnicStyle: $e');
      throw Exception('Failed to generate ethnic style: $e');
    }
  }

  // Kullanıcının fiziksel özelliklerini analiz et
  Future<Map<String, String>> _analyzeUserFeatures(String userPhotoPath) async {
    Map<String, String> features = {
      'skinTone': 'medium',
      'hairColor': 'brown',
      'eyeColor': 'brown',
      'facialHair': 'none',
    };
    
    try {
      // Resmi yükle
      File imageFile = File(userPhotoPath);
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image != null) {
        // Ten rengi analizi
        final brightness = _extractFaceBrightness(image);
        if (brightness > 170) features['skinTone'] = 'very light';
        else if (brightness > 150) features['skinTone'] = 'light';
        else if (brightness > 120) features['skinTone'] = 'medium light';
        else if (brightness > 90) features['skinTone'] = 'medium';
        else if (brightness > 70) features['skinTone'] = 'tan';
        else if (brightness > 50) features['skinTone'] = 'medium dark';
        else features['skinTone'] = 'dark';
        
        // Dominant renkler analizi
        List<Color> dominantColors = _extractDominantColors(image);
        if (dominantColors.isNotEmpty) {
          // Saç rengi tahmini (genellikle daha koyu renk)
          Color? estimatedHairColor = _findDarkestColor(dominantColors);
          if (estimatedHairColor != null) {
            features['hairColor'] = _getColorDescription(estimatedHairColor);
          }
          
          // Göz rengi tahmini
          if (dominantColors.length > 1) {
            Color? estimatedEyeColor = dominantColors[1]; // İkinci dominant renk genellikle göz rengidir
            if (estimatedEyeColor != null) {
              String eyeColorDesc = _getColorDescription(estimatedEyeColor);
              // Göz rengi için daha spesifik tanımlar
              if (eyeColorDesc.contains('blue')) features['eyeColor'] = 'blue';
              else if (eyeColorDesc.contains('green')) features['eyeColor'] = 'green';
              else if (eyeColorDesc.contains('brown')) features['eyeColor'] = 'brown';
              else if (eyeColorDesc.contains('hazel')) features['eyeColor'] = 'hazel';
              else if (eyeColorDesc.contains('gray')) features['eyeColor'] = 'gray';
              else features['eyeColor'] = 'brown'; // Varsayılan
            }
          }
          
          // Sakal analizi için basit tahmin - tamamen kesin olması zor
          // Gerçek uygulamada yüz tanıma veya daha gelişmiş görüntü işleme kullanılmalıdır
          bool hasDarkPixelsInChinArea = _checkForDarkPixelsInChinArea(image);
          features['facialHair'] = hasDarkPixelsInChinArea ? 'beard' : 'none';
        }
      }
    } catch (e) {
      print('Error analyzing user features: $e');
    }
    
    return features;
  }

  // Çene bölgesinde koyu pikseller var mı kontrol et (basit sakal tahmini)
  bool _checkForDarkPixelsInChinArea(img.Image image) {
    try {
      // Görüntünün alt yarısında ve orta bölgesinde koyu piksel sayısını hesapla
      int darkPixelCount = 0;
      int totalPixels = 0;
      
      int startY = (image.height * 0.6).toInt(); // Alt yarı
      int startX = (image.width * 0.3).toInt(); // Orta bölge
      int endX = (image.width * 0.7).toInt();
      
      for (int y = startY; y < image.height; y++) {
        for (int x = startX; x < endX; x++) {
          final pixel = image.getPixel(x, y);
          final r = pixel.r.toInt();
          final g = pixel.g.toInt();
          final b = pixel.b.toInt();
          
          // Pikselin parlaklığını hesapla
          final brightness = (r + g + b) / 3;
          
          // Koyu piksel olarak kabul et
          if (brightness < 80) {
            darkPixelCount++;
          }
          totalPixels++;
        }
      }
      
      // Koyu piksellerin oranı belirli bir eşiği geçerse sakal var olarak kabul et
      return totalPixels > 0 && (darkPixelCount / totalPixels) > 0.2;
    } catch (e) {
      print('Error checking for facial hair: $e');
      return false;
    }
  }

  // Bir dizi renk içinde en koyu olanı bul
  Color? _findDarkestColor(List<Color> colors) {
    if (colors.isEmpty) return null;
    
    Color darkestColor = colors[0];
    double darkestBrightness = _calculateBrightness(darkestColor);
    
    for (int i = 1; i < colors.length; i++) {
      double brightness = _calculateBrightness(colors[i]);
      if (brightness < darkestBrightness) {
        darkestBrightness = brightness;
        darkestColor = colors[i];
      }
    }
    
    return darkestColor;
  }

  // Renk parlaklığını hesapla
  double _calculateBrightness(Color color) {
    return (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114) / 255;
  }

  // Ana modelle etnik stil oluştur
  Future<String> _generateEthnicWithMainModel(String apiKey, String gender, String ethnicStyle, Map<String, String> userFeatures) async {
    final modelUrl = 'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0';
    final prompt = _buildEthnicPrompt(ethnicStyle, gender, userFeatures);
    final negativePrompt = _buildEthnicNegativePrompt();
    
    // API'yi çağır
    final response = await http.post(
      Uri.parse(modelUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "inputs": prompt,
        "parameters": {
          "negative_prompt": negativePrompt,
          "num_inference_steps": 50,
          "guidance_scale": 8.5,
          "width": 768,
          "height": 768,
          "seed": math.Random().nextInt(2147483647)
        }
      }),
    );
    
    print('API response status code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      // Başarılı yanıt, byte dizisini al
      final resultBytes = response.bodyBytes;
      
      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final imagePath = '${tempDir.path}/ethnic_style_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Sonucu kaydet
      await File(imagePath).writeAsBytes(resultBytes);
      print('Ethnic style image created: $imagePath');
      return imagePath;
    } else {
      // Hata durumunu logla
      print('API Error: ${response.statusCode}, ${response.body}');
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  // Alternatif modelle etnik stil oluştur
  Future<String> _generateEthnicWithAlternativeModel(String apiKey, String gender, String ethnicStyle, Map<String, String> userFeatures) async {
    final modelUrl = 'https://api-inference.huggingface.co/models/SG161222/Realistic_Vision_V5.0';
    final prompt = _buildEthnicPrompt(ethnicStyle, gender, userFeatures);
    final negativePrompt = _buildEthnicNegativePrompt();
    
    // API'yi çağır
    final response = await http.post(
      Uri.parse(modelUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "inputs": prompt,
        "parameters": {
          "negative_prompt": negativePrompt,
          "num_inference_steps": 45,
          "guidance_scale": 7.5,
          "width": 768,
          "height": 768,
          "seed": math.Random().nextInt(2147483647)
        }
      }),
    );
    
    print('Alternative API response status code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      // Başarılı yanıt, byte dizisini al
      final resultBytes = response.bodyBytes;
      
      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final imagePath = '${tempDir.path}/ethnic_style_alt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Sonucu kaydet
      await File(imagePath).writeAsBytes(resultBytes);
      print('Alternative ethnic style image created: $imagePath');
      return imagePath;
    } else {
      // Hata durumunu logla
      print('API Error: ${response.statusCode}, ${response.body}');
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  // Yedek modelle etnik stil oluştur
  Future<String> _generateEthnicWithBackupModel(String apiKey, String gender, String ethnicStyle, Map<String, String> userFeatures) async {
    final modelUrl = 'https://api-inference.huggingface.co/models/runwayml/stable-diffusion-v1-5';
    final prompt = _buildEthnicPrompt(ethnicStyle, gender, userFeatures);
    final negativePrompt = _buildEthnicNegativePrompt();
    
    // API'yi çağır
    final response = await http.post(
      Uri.parse(modelUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "inputs": prompt,
        "parameters": {
          "negative_prompt": negativePrompt,
          "num_inference_steps": 40,
          "guidance_scale": 7.5,
          "width": 512,
          "height": 512,
          "seed": math.Random().nextInt(2147483647)
        }
      }),
    );
    
    print('Backup API response status code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      // Başarılı yanıt, byte dizisini al
      final resultBytes = response.bodyBytes;
      
      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final imagePath = '${tempDir.path}/ethnic_style_backup_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Sonucu kaydet
      await File(imagePath).writeAsBytes(resultBytes);
      print('Backup ethnic style image created: $imagePath');
      return imagePath;
    } else {
      // Hata durumunu logla
      print('API Error: ${response.statusCode}, ${response.body}');
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  // Etnik stil prompt'u oluştur - kullanıcının özelliklerini koruyarak
  String _buildEthnicPrompt(String ethnicStyle, String gender, Map<String, String> userFeatures) {
    final String personType = gender == 'male' ? "man" : "woman";
    final String skinTone = userFeatures['skinTone'] ?? 'medium';
    final String hairColor = userFeatures['hairColor'] ?? 'brown';
    final String eyeColor = userFeatures['eyeColor'] ?? 'brown';
    final String facialHair = userFeatures['facialHair'] ?? 'none';
    final String facialHairText = (gender == 'male' && facialHair == 'beard') ? 'with beard' : '';
    
    Map<String, String> styleSpecifics = {
      'African': 'traditional African clothing with intricate patterns and vibrant colors, kente cloth, ankara fabric, cultural accessories',
      'Indian': 'traditional Indian ${gender == "male" ? "kurta pajama with turban" : "saree with intricate gold embroidery"}, ornate jewelry, cultural setting',
      'Japanese': 'traditional Japanese ${gender == "male" ? "kimono with hakama" : "kimono with obi"}, tatami mat background, cherry blossoms',
      'Middle Eastern': 'traditional Middle Eastern ${gender == "male" ? "thobe and keffiyeh" : "abaya with intricate embroidery"}, ornate accessories',
      'Native American': 'traditional Native American ${gender == "male" ? "regalia" : "dress with turquoise jewelry"}, cultural patterns',
      'Nordic': 'traditional Nordic folk costume, ${gender == "male" ? "embroidered vest" : "embroidered dress with bonnet"}, nordic setting',
      'South American': 'traditional South American ${gender == "male" ? "poncho" : "colorful folkloric dress"}, vibrant textile patterns',
      'Thai': 'traditional Thai ${gender == "male" ? "silk shirt and pants" : "silk dress with sabai"}, ornate headdress, thai setting',
    };
    
    // Etnik kökenin yüz özelliklerini belirten özel ayarlamalar
    Map<String, String> faceAdjustments = {
      'Japanese': 'with slightly almond-shaped eyes', 
      'Middle Eastern': 'with defined facial features',
      'Native American': 'with high cheekbones',
      'African': '',
      'Indian': '',
      'Nordic': '',
      'South American': '',
      'Thai': 'with subtle Asian features',
    };
    
    String styleDetails = styleSpecifics[ethnicStyle] ?? 'traditional ethnic clothing with cultural patterns and accessories';
    String faceAdjustment = faceAdjustments[ethnicStyle] ?? '';
    
    // Kullanıcının özellikleri + seçilen etnik stilin minimal yüz özellikleri
    return '''
    ultra-realistic portrait photograph of a $skinTone skin $personType with $hairColor hair and $eyeColor eyes $facialHairText $faceAdjustment,
    wearing $styleDetails,
    preserved original face structure, features, and coloring, 
    shot with Sony Alpha 7R IV camera at f/2.8 aperture, 85mm lens, ISO 100, 1/125 sec shutter speed,
    professional studio lighting with soft key light and fill light, cultural studio backdrop, 
    high-end fashion photography, 8k resolution, photorealistic, centered framing,
    detailed facial features, rich colors, accurate skin tone, perfect likeness,
    clear detailed photo, head and shoulders portrait
    ''';
  }

  // Etnik stil negatif prompt'u oluştur - daha güçlü cilt rengi kontrolü
  String _buildEthnicNegativePrompt() {
    return '''
    cartoon, animation, illustration, drawing, painting, sketch, anime, 
    distorted features, unrealistic, low quality, blurry, noise,
    multiple people, deformed proportions, bad anatomy, different face,
    changed skin tone, changed eye color, changed hair color, 
    extra limbs, disfigured, oversaturated, over-exposed,
    poor likeness, missing resemblance
    ''';
  }
} 