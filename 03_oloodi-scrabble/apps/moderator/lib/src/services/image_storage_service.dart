// lib/src/services/image_storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'firebase_error_handler.dart';

class ImageStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Singleton pattern
  static final ImageStorageService _instance = ImageStorageService._internal();
  
  factory ImageStorageService() {
    return _instance;
  }
  
  ImageStorageService._internal();

  // Upload an image file with progress tracking
  Future<String> uploadImage({
    required String imagePath,
    required String directory,
    required String fileName,
    Map<String, String>? metadata,
    Function(double progress)? onProgress,
  }) async {
    return FirebaseErrorHandler.wrap(
      operation: 'image_upload',
      action: () async {
        final File file = File(imagePath);
        if (!await file.exists()) {
          throw Exception('Image file not found at $imagePath');
        }

        // Create storage reference
        final String fullPath = '$directory/$fileName${path.extension(imagePath)}';
        final ref = _storage.ref().child(fullPath);

        // Set up upload task
        final uploadTask = ref.putFile(
          file,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: metadata,
          ),
        );

        // Monitor upload progress
        if (onProgress != null) {
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            onProgress(progress);
          });
        }

        // Wait for upload to complete
        await uploadTask;

        // Return the download URL
        return await ref.getDownloadURL();
      },
    );
  }

  // Upload a move image specifically for the game
  Future<String> uploadMoveImage({
    required String sessionId,
    required String imagePath,
    required int moveNumber,
    Function(double progress)? onProgress,
  }) async {
    final fileName = 'move_$moveNumber';
    final metadata = {
      'sessionId': sessionId,
      'moveNumber': moveNumber.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    return uploadImage(
      imagePath: imagePath,
      directory: 'moves/$sessionId',
      fileName: fileName,
      metadata: metadata,
      onProgress: onProgress,
    );
  }

  // Delete an image
  Future<void> deleteImage(String imagePath) async {
    await FirebaseErrorHandler.wrap(
      operation: 'image_delete',
      action: () => _storage.ref(imagePath).delete(),
    );
  }

  // Get image metadata
  Future<Map<String, String>> getImageMetadata(String imagePath) async {
    return FirebaseErrorHandler.wrap(
      operation: 'get_image_metadata',
      action: () async {
        final metadata = await _storage.ref(imagePath).getMetadata();
        return metadata.customMetadata ?? {};
      },
    );
  }

  // List all images in a directory
  Future<List<String>> listImages(String directory) async {
    return FirebaseErrorHandler.wrap(
      operation: 'list_images',
      action: () async {
        final result = await _storage.ref(directory).listAll();
        return await Future.wait(
          result.items.map((ref) => ref.getDownloadURL()),
        );
      },
    );
  }

  // Download image to a local file
  Future<File> downloadImage(String imagePath, String localPath) async {
    return FirebaseErrorHandler.wrap(
      operation: 'download_image',
      action: () async {
        final File file = File(localPath);
        await _storage.ref(imagePath).writeToFile(file);
        return file;
      },
    );
  }
}