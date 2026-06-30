import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

Future<String> getVideoUrlImpl(String assetPath) async {
  final directory = await getTemporaryDirectory();
  final fileName = assetPath.replaceAll('/', '_').replaceAll('\\', '_');
  final localFile = File('${directory.path}/$fileName');
  final tempFile = File('${localFile.path}.tmp');

  bool needsCopy = true;

  if (await localFile.exists()) {
    final byteData = await rootBundle.load(assetPath);
    final localLength = await localFile.length();
    if (localLength == byteData.lengthInBytes) {
      needsCopy = false;
    }
  }

  if (needsCopy) {
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    await tempFile.writeAsBytes(bytes, flush: true);
    await tempFile.rename(localFile.path);
  }
  return localFile.path;
}
