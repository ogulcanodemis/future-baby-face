import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_image.dart';

class StorageService {
  static const String _parent1Key = 'parent1_image';
  static const String _parent2Key = 'parent2_image';
  static const String _babyImageKey = 'baby_image';

  // Ebeveyn 1 resmini kaydet
  Future<void> saveParent1Image(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final userImage = UserImage(path: path, isParent1: true);
    await prefs.setString(_parent1Key, jsonEncode(userImage.toJson()));
  }

  // Ebeveyn 2 resmini kaydet
  Future<void> saveParent2Image(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final userImage = UserImage(path: path, isParent1: false);
    await prefs.setString(_parent2Key, jsonEncode(userImage.toJson()));
  }

  // Bebek resmini kaydet
  Future<void> saveBabyImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_babyImageKey, path);
  }

  // Ebeveyn 1 resmini getir
  Future<String?> getParent1Image() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_parent1Key);
    if (jsonStr == null) return null;
    
    final userImage = UserImage.fromJson(jsonDecode(jsonStr));
    return userImage.path;
  }

  // Ebeveyn 2 resmini getir
  Future<String?> getParent2Image() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_parent2Key);
    if (jsonStr == null) return null;
    
    final userImage = UserImage.fromJson(jsonDecode(jsonStr));
    return userImage.path;
  }

  // Bebek resmini getir
  Future<String?> getBabyImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_babyImageKey);
  }

  // Tüm resimleri temizle
  Future<void> clearAllImages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_parent1Key);
    await prefs.remove(_parent2Key);
    await prefs.remove(_babyImageKey);
  }
} 