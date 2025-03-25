import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/ethnic_style.dart';
import 'dart:math' as math;

class EthnicStyleService {
  // Hugging Face API endpointleri
  static const String sdxlApiUrl = 'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0';
  static const String controlNetApiUrl = 'https://api-inference.huggingface.co/models/lllyasviel/sd-controlnet-openpose';
  static const String backupApiUrl = 'https://api-inference.huggingface.co/models/runwayml/stable-diffusion-v1-5';
  
  // API anahtarı
  late final String _apiKey;
  
  // Cinsiyet tercihi
  static const Map<String, String> genderTerms = {
    'male': 'male',
    'female': 'female',
    'neutral': '',
  };

  EthnicStyleService() {
    _apiKey = dotenv.env['HF_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      print('UYARI: HF_API_KEY tanımlanmamış. .env dosyasını kontrol edin.');
    }
  }
  
  // Kullanıcı fotoğrafını ve seçilen etnik stili kullanarak görüntü oluşturma
  Future<String> generateEthnicOutfit(String userPhotoPath, String ethnicStyleId, String gender) async {
    try {
      if (_apiKey.isEmpty) {
        throw Exception('API anahtarı bulunamadı. Lütfen .env dosyasını kontrol edin.');
      }

      // Etnik stil bilgilerini al
      final ethnicStyle = EthnicStyle.getStyleById(ethnicStyleId);
      if (ethnicStyle == null) {
        throw Exception('Geçersiz etnik stil ID\'si: $ethnicStyleId');
      }

      print('Etnik stil için görüntü oluşturuluyor: ${ethnicStyle.name}');
      
      // Cinsiyet terimini al (template içinde kullanılacak)
      final genderTerm = genderTerms[gender.toLowerCase()] ?? '';
      
      // Promptu hazırla (cinsiyet terimini yer değiştirerek)
      final prompt = ethnicStyle.promptTemplate.replaceAll('{gender}', genderTerm);
      
      try {
        // Ana model ile görüntü oluştur (SDXL)
        return await _generateWithSDXL(userPhotoPath, prompt, ethnicStyle, genderTerm);
      } catch (e) {
        print('Ana model hatası: $e, alternatif modele geçiliyor...');
        
        // Backup model ile dene
        try {
          return await _generateWithBackupModel(userPhotoPath, prompt, ethnicStyle, genderTerm);
        } catch (e2) {
          print('Alternatif model hatası: $e2');
          throw Exception('Etnik stil görüntüsü oluşturulamadı.');
        }
      }
    } catch (e) {
      print('Etnik stil servisi hatası: $e');
      rethrow;
    }
  }
  
  // SDXL model ile görüntü oluşturma
  Future<String> _generateWithSDXL(
    String userPhotoPath, 
    String prompt, 
    EthnicStyle style,
    String genderTerm
  ) async {
    print('SDXL model kullanılıyor...');
    
    final negativePrompt = """
      deformed, distorted, disfigured, poorly drawn, bad anatomy, wrong anatomy, 
      extra limb, missing limb, floating limbs, disconnected limbs, mutation, mutated, 
      ugly, disgusting, blurry, amputation, duplicate, incorrect facial features, incorrect face, 
      duplicate heads, multiple heads, poorly rendered hands, poorly rendered face, elongated limbs, 
      unrealistic features, wrong colors, cartoon, anime, digital art style, drawing
    """;
    
    // Random seed değeri
    final seed = math.Random().nextInt(2147483647);
    
    final response = await http.post(
      Uri.parse(sdxlApiUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "inputs": prompt,
        "parameters": {
          "negative_prompt": negativePrompt,
          "num_inference_steps": 75,
          "guidance_scale": 8.5,
          "width": 832,
          "height": 1024,
          "seed": seed
        }
      }),
    );
    
    print('SDXL API cevap kodu: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      // Başarılı cevap, byte dizisini al
      final resultBytes = response.bodyBytes;
      
      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/ethnic_style_${style.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Sonucu kaydet
      await File(outputPath).writeAsBytes(resultBytes);
      print('Etnik stil görüntüsü oluşturuldu: $outputPath');
      return outputPath;
    } else {
      // Hata durumu
      print('SDXL API Hata: ${response.statusCode} - ${response.body}');
      throw Exception('SDXL API hatası: ${response.statusCode}');
    }
  }
  
  // Yedek model ile görüntü oluşturma (SD 1.5)
  Future<String> _generateWithBackupModel(
    String userPhotoPath, 
    String prompt, 
    EthnicStyle style,
    String genderTerm
  ) async {
    print('Yedek model (SD 1.5) kullanılıyor...');
    
    final negativePrompt = """
      deformed, distorted, disfigured, poorly drawn, bad anatomy, wrong anatomy, 
      extra limb, missing limb, floating limbs, disconnected limbs, mutation, mutated, 
      ugly, disgusting, blurry, amputation
    """;
    
    // Random seed değeri
    final seed = math.Random().nextInt(2147483647);
    
    final response = await http.post(
      Uri.parse(backupApiUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "inputs": prompt,
        "parameters": {
          "negative_prompt": negativePrompt,
          "num_inference_steps": 50,
          "guidance_scale": 7.5,
          "width": 512,
          "height": 768,
          "seed": seed
        }
      }),
    );
    
    print('Yedek model API cevap kodu: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      // Başarılı cevap, byte dizisini al
      final resultBytes = response.bodyBytes;
      
      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/ethnic_style_backup_${style.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Sonucu kaydet
      await File(outputPath).writeAsBytes(resultBytes);
      print('Etnik stil görüntüsü oluşturuldu (yedek model): $outputPath');
      return outputPath;
    } else {
      // Hata durumu
      print('Yedek model API Hata: ${response.statusCode} - ${response.body}');
      throw Exception('Yedek model API hatası: ${response.statusCode}');
    }
  }
} 