# Omni Media Picker

A Flutter plugin to capture multiple media from the device with a beautiful, professional camera interface.

## Features

- 📸 **Multiple Image Capture**: Capture up to a specified number of images
- 🎨 **Professional UI**: Clean, modern camera interface with thumbnails
- 🔄 **Real-time Preview**: See captured images immediately with delete option
- 📱 **Fullscreen Experience**: Immersive camera interface
- 🖼️ **Image Viewer**: Tap thumbnails to view full-size images
- ⚡ **Smooth Animations**: Professional capture feedback and transitions
- 🎯 **Customizable**: Configurable resolution and maximum image count

## Getting Started

### Prerequisites

Add the required permissions to your platform-specific files:

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="true" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture photos</string>
```

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  omni_media_picker: ^0.1.0
```

Then run:
```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:omni_media_picker/omni_media_picker.dart';

// Capture multiple images
final images = await OmniCameraPicker.capture(
  context: context,
  maxImages: 5,
);

print('Captured ${images.length} images');
```

### Advanced Usage

```dart
// Capture with custom resolution
final images = await OmniCameraPicker.capture(
  context: context,
  maxImages: 10,
  resolution: ResolutionPreset.high,
);

// Process captured images
for (final image in images) {
  print('Image path: ${image.path}');
  // Do something with each image
}
```

### Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:omni_media_picker/omni_media_picker.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<XFile> capturedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Demo')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final images = await OmniCameraPicker.capture(
                context: context,
                maxImages: 5,
              );
              if (images.isNotEmpty) {
                setState(() {
                  capturedImages = images;
                });
              }
            },
            child: Text('Capture Images'),
          ),
          if (capturedImages.isNotEmpty)
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: capturedImages.length,
                itemBuilder: (context, index) {
                  return Image.file(
                    File(capturedImages[index].path),
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
```

## API Reference

### OmniCameraPicker.capture()

Opens a full-screen camera interface and returns captured images.

**Parameters:**
- `context` (required): BuildContext for navigation
- `maxImages` (required): Maximum number of images to capture
- `resolution` (optional): Camera resolution preset (default: `ResolutionPreset.medium`)

**Returns:**
- `Future<List<XFile>>`: List of captured image files

**Example:**
```dart
final images = await OmniCameraPicker.capture(
  context: context,
  maxImages: 5,
  resolution: ResolutionPreset.high,
);
```

## Error Handling

The package handles common camera errors gracefully:

- **No cameras found**: Shows error dialog and returns to previous screen
- **Camera initialization failed**: Displays error message with details
- **Permission denied**: Handled by your app's permission logic

## Permissions

This package requires camera permissions. Handle permissions in your app:

```dart
// Example permission handling
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();
  return status.isGranted;
}

// Use before calling OmniCameraPicker.capture()
if (await requestCameraPermission()) {
  final images = await OmniCameraPicker.capture(
    context: context,
    maxImages: 5,
  );
}
```

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web (with limitations)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Changelog

### 0.0.1
- Initial release
- Multiple image capture
- Professional camera UI
- Thumbnail preview
- Fullscreen image viewer
- Error handling