// lib/screens/photo_gallery_screen.dart
//
// 라운드 사진 전체보기 / 확대 화면

import 'dart:io';

import 'package:flutter/material.dart';

class PhotoGalleryScreen extends StatefulWidget {
  final List<String> photoPaths;
  final int initialIndex;

  const PhotoGalleryScreen({
    super.key,
    required this.photoPaths,
    required this.initialIndex,
  });

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${currentIndex + 1}/${widget.photoPaths.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photoPaths.length,
        onPageChanged: (i) => setState(() => currentIndex = i),
        itemBuilder: (_, i) {
          final path = widget.photoPaths[i];
          return InteractiveViewer(
            child: Image.file(
              File(path),
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
