import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PostImage extends StatelessWidget {
  const PostImage({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(
            image,
          ),
          filterQuality: FilterQuality.high,
          tightMode: true,
        ),
      ),
    );
  }
}
