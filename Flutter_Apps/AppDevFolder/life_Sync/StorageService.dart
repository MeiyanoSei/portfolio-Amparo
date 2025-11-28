import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StorageService {
  final String userId;
  late final FirebaseStorage _storage;

  StorageService({required this.userId}) {
    _storage = FirebaseStorage.instance;
  }

  // Upload profile picture
  Future<String?> uploadProfilePicture(XFile imageFile) async {
    try {
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref('users/$userId/profile/$fileName');
      
      // Convert XFile to File
      final file = File(imageFile.path);
      await ref.putFile(file);
      
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  // Upload task attachment
  Future<String?> uploadTaskAttachment(XFile file, String taskId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final ref = _storage.ref('users/$userId/tasks/$taskId/$fileName');
      
      // Convert XFile to File
      final fileToUpload = File(file.path);
      await ref.putFile(fileToUpload);
      
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading task attachment: $e');
      return null;
    }
  }

  // Delete file
  Future<void> deleteFile(String filePath) async {
    try {
      await _storage.ref(filePath).delete();
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  // Get download URL
  Future<String?> getDownloadURL(String filePath) async {
    try {
      return await _storage.ref(filePath).getDownloadURL();
    } catch (e) {
      print('Error getting URL: $e');
      return null;
    }
  }

  // List all files in a folder
  Future<List<String>> listFiles(String folderPath) async {
    try {
      final result = await _storage.ref(folderPath).listAll();
      final urls = <String>[];
      for (var file in result.items) {
        final url = await file.getDownloadURL();
        urls.add(url);
      }
      return urls;
    } catch (e) {
      print('Error listing files: $e');
      return [];
    }
  }
}