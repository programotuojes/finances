import 'package:finances/transaction/models/attachment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

const _background = Colors.black26;

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
    var screenSize = MediaQuery.of(context).size;

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
            for (var i in boundingBoxes)
              Positioned.fromRect(
                rect: i.scale(screenSize.width / 550),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red.withOpacity(0.8),
                      width: 0.5,
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

extension RectExtension on Rect {
  Rect scale(double scale) {
    double left = this.left * scale;
    double top = this.top * scale;
    double right = this.right * scale;
    double bottom = this.bottom * scale;
    return Rect.fromLTRB(left, top, right, bottom);
  }
}
