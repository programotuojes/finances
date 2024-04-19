import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

final _buttonBackground = Colors.black.withOpacity(0.3);

class ImageViewer extends StatelessWidget {
  const ImageViewer({
    super.key,
    required this.imageProvider,
    required this.tag,
  });

  final ImageProvider imageProvider;
  final Object tag;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: _buttonBackground,
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
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: BackButton(
                  color: Colors.white,
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      _buttonBackground,
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
