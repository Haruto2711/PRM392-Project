import 'video_helper_non_web.dart'
    if (dart.library.html) 'video_helper_web.dart';

class VideoHelper {
  static Future<String> getVideoUrl(String assetPath) {
    return getVideoUrlImpl(assetPath);
  }
}
