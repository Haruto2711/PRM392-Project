import 'package:flutter/material.dart';

class OrigamiCoverImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;

  const OrigamiCoverImage({
    Key? key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Nếu là ảnh bìa Complete.png, chỉ hiển thị nửa bên trái (phần ảnh chụp thực tế đã hoàn thành)
    if (imagePath.endsWith('Complete.png')) {
      return SizedBox(
        width: width,
        height: height,
        child: ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 0.5,
            child: Image.asset(
              imagePath,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.menu_book, size: 48, color: Colors.indigo),
              ),
            ),
          ),
        ),
      );
    }

    return Image.asset(
      imagePath,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.menu_book, size: 48, color: Colors.indigo),
      ),
    );
  }
}
