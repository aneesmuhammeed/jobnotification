import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jobnoti/core/constants/app_constants.dart';
import 'package:path_provider/path_provider.dart';

class TelegramService {
  final String _botToken = AppConstants.telegramBotToken;
  final String _chatId = AppConstants.telegramChatId;

  /// Uploads a document to Telegram and returns the Telegram file_id.
  Future<String> uploadDocument(File file, String fileName) async {
    final url = Uri.parse('https://api.telegram.org/bot$_botToken/sendDocument');
    
    final request = http.MultipartRequest('POST', url)
      ..fields['chat_id'] = _chatId
      ..files.add(await http.MultipartFile.fromPath(
        'document',
        file.path,
        filename: fileName,
      ));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(responseData);
      if (json['ok'] == true) {
        // Extract file_id from the response
        final document = json['result']['document'];
        return document['file_id'] as String;
      }
    }
    
    throw Exception('Failed to upload document to Telegram: $responseData');
  }

  /// Gets the direct download URL for a given file_id.
  Future<String> _getFileDownloadUrl(String fileId) async {
    final url = Uri.parse('https://api.telegram.org/bot$_botToken/getFile?file_id=$fileId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['ok'] == true) {
        final filePath = json['result']['file_path'];
        return 'https://api.telegram.org/file/bot$_botToken/$filePath';
      }
    }
    
    throw Exception('Failed to get file path from Telegram');
  }

  /// Downloads the file from Telegram (if not already cached) and returns the local file path.
  Future<String> downloadDocument(String fileId, String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/${AppConstants.documentsDir}');
    
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final localFile = File('${cacheDir.path}/$fileId\_$fileName');

    // If we already downloaded it before, return the cached path instantly!
    if (await localFile.exists()) {
      return localFile.path;
    }

    // Otherwise, fetch a fresh 1-hour URL and download it
    final downloadUrl = await _getFileDownloadUrl(fileId);
    
    final response = await http.get(Uri.parse(downloadUrl));
    if (response.statusCode == 200) {
      await localFile.writeAsBytes(response.bodyBytes);
      return localFile.path;
    } else {
      throw Exception('Failed to download document from Telegram');
    }
  }
}
