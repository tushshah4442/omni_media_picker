import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_file.dart';

/// OmniCameraPicker opens a full-screen camera UI and
/// returns a list of captured images as XFile objects.
class OmniCameraPicker {
  static Future<List<XFile>> capture({
    required BuildContext context,
    required int maxImages,
    ResolutionPreset resolution = ResolutionPreset.medium,
  }) async {
    final images = await Navigator.push<List<XFile>>(
      context,
      MaterialPageRoute(
        builder: (_) => CameraFile(
          maxImages: maxImages,
          resolution: resolution,
        ),
      ),
    );
    return images ?? <XFile>[];
  }
}
