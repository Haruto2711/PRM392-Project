// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/services.dart' show rootBundle;

Future<String> getVideoUrlImpl(String assetPath) async {
  final byteData = await rootBundle.load(assetPath);
  final bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  final blob = html.Blob([bytes], 'video/mp4');
  final blobUrl = html.Url.createObjectUrlFromBlob(blob);
  return blobUrl;
}
