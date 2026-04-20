import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:snapconnect/core/constants/app_constants.dart';
import 'package:universal_io/io.dart';

/// Upload service that sends images to Cloudinary unsigned presets.
final class CloudinaryService {
  CloudinaryService._();

  static final CloudinaryService instance = CloudinaryService._();

  /// Uploads a local file to Cloudinary and returns the secure URL.
  Future<String?> uploadImage(File file, {String? folder}) async {
    final request = await _createRequest(folder: folder);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    return _send(request);
  }

  /// Uploads an XFile to Cloudinary and returns the secure URL.
  Future<String?> uploadXFile(XFile file, {String? folder}) async {
    final request = await _createRequest(folder: folder);

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: file.name),
      );
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    return _send(request);
  }

  Future<http.MultipartRequest> _createRequest({String? folder}) async {
    if (!AppConstants.hasCloudinaryConfig) {
      throw StateError('Cloudinary is not configured. Check your .env values.');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
    );

    return http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConstants.cloudinaryUploadPreset
      ..fields['folder'] = folder ?? AppConstants.cloudinaryFolder;
  }

  Future<String?> _send(http.MultipartRequest request) async {
    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      return null;
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['secure_url'] as String?;
  }
}
