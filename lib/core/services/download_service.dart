import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:universal_io/io.dart';

/// Handles downloading single photos and creating album ZIP archives.
final class DownloadService {
  DownloadService._();

  static final DownloadService instance = DownloadService._();
  final Dio _dio = Dio();

  /// Downloads one photo and returns the local saved path.
  Future<String?> downloadSinglePhoto(
    String url, {
    String? fileName,
    void Function(int received, int total)? onProgress,
  }) async {
    if (kIsWeb) {
      Fluttertoast.showToast(msg: 'On web, open the image URL and save from browser.');
      return url;
    }

    final allowed = await _ensureStoragePermission();
    if (!allowed) {
      Fluttertoast.showToast(msg: 'Storage permission denied');
      return null;
    }

    final directory = await _preferredDownloadsDirectory();
    if (directory == null) {
      Fluttertoast.showToast(msg: 'Could not access local storage');
      return null;
    }

    final safeName = _sanitizeFileName(
      fileName ?? 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final outputPath = '${directory.path}/$safeName';

    await _dio.download(
      url,
      outputPath,
      onReceiveProgress: onProgress,
      options: Options(responseType: ResponseType.bytes),
    );

    Fluttertoast.showToast(msg: 'Photo saved to gallery');
    return outputPath;
  }

  /// Downloads all photo URLs and creates a ZIP archive.
  Future<String?> downloadAlbumAsZip({
    required List<PhotoModel> photos,
    required String albumName,
  }) async {
    if (photos.isEmpty) {
      return null;
    }

    if (kIsWeb) {
      Fluttertoast.showToast(msg: 'ZIP download is available on mobile and desktop.');
      return null;
    }

    final allowed = await _ensureStoragePermission();
    if (!allowed) {
      Fluttertoast.showToast(msg: 'Storage permission denied');
      return null;
    }

    final directory = await _preferredDownloadsDirectory();
    if (directory == null) {
      Fluttertoast.showToast(msg: 'Could not access local storage');
      return null;
    }

    final archive = Archive();

    for (var i = 0; i < photos.length; i++) {
      final photo = photos[i];
      try {
        final response = await _dio.get<List<int>>(
          photo.url,
          options: Options(responseType: ResponseType.bytes),
        );

        final bytes = response.data;
        if (bytes == null || bytes.isEmpty) {
          continue;
        }

        final fileName = _sanitizeFileName('photo_${i + 1}.jpg');
        archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
      } catch (_) {
        // Continue with remaining files to avoid full failure.
      }
    }

    final encoded = ZipEncoder().encode(archive);
    if (encoded == null || encoded.isEmpty) {
      Fluttertoast.showToast(msg: 'Failed to create ZIP archive');
      return null;
    }

    final zipName = _sanitizeFileName('${albumName}_album.zip');
    final zipPath = '${directory.path}/$zipName';
    final zipFile = File(zipPath);
    await zipFile.writeAsBytes(encoded, flush: true);

    await Share.shareXFiles([XFile(zipPath)], text: 'Album ZIP: $albumName');
    return zipPath;
  }

  Future<bool> _ensureStoragePermission() async {
    if (kIsWeb) {
      return true;
    }

    if (Platform.isIOS || Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return true;
    }

    final status = await Permission.storage.request();
    return status.isGranted || status.isLimited;
  }

  Future<Directory?> _preferredDownloadsDirectory() async {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) {
      return downloads;
    }
    return getApplicationDocumentsDirectory();
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
}
