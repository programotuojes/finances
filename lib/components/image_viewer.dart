import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({
    super.key,
    required this.imageProvider,
    required this.tag,
  });

  static const _background = Colors.black26;
  final ImageProvider imageProvider;
  final Object tag;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: _background,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: [
            PhotoView(
              imageProvider: imageProvider,
              minScale: PhotoViewComputedScale.contained,
              heroAttributes: PhotoViewHeroAttributes(tag: tag),
            ),
            const SafeArea(
              child: Padding(
                padding: EdgeInsets.all(4),
                child: BackButton(
                  color: Colors.white,
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      _background,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
