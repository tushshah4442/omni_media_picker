import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

class CameraFile extends StatefulWidget {
  final int maxImages;
  final ResolutionPreset resolution;

  const CameraFile({
    Key? key,
    required this.maxImages,
    this.resolution = ResolutionPreset.medium,
  }) : super(key: key);

  @override
  State<CameraFile> createState() => _CameraFileState();
}

class _CameraFileState extends State<CameraFile> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  List<XFile> _capturedImages = [];
  bool _isCameraInitialized = false;
  bool _isBusy = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    // Hide system UI for fullscreen camera experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Lock orientation to portrait to prevent UI mess
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          _showErrorDialog('No cameras found on this device');
        }
        return;
      }
      
      _controller = CameraController(
        _cameras.first,
        widget.resolution,
        enableAudio: false,
      );
      
      await _controller!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to initialize camera: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    // Restore system UI when leaving camera
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, 
        overlays: SystemUiOverlay.values);
    // Restore orientation when leaving camera
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_capturedImages.length >= widget.maxImages) return;

    setState(() {
      _isBusy = true;
      _isCapturing = true;
    });
    
    try {
      final file = await _controller!.takePicture();
      if (mounted) {
        setState(() => _capturedImages.add(file));
        // Add a small delay to show the capture animation
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _isCapturing = false;
        });
      }
    }
  }

  void _switchCamera() async {
    if (_cameras.length < 2) return;
    final lensDirection = _controller!.description.lensDirection;
    final newDescription = _cameras.firstWhere(
          (camera) =>
      camera.lensDirection ==
          (lensDirection == CameraLensDirection.front
              ? CameraLensDirection.back
              : CameraLensDirection.front),
    );
    await _controller!.dispose();
    _controller = CameraController(
      newDescription,
      widget.resolution,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  void _removeImage(int index) {
    setState(() => _capturedImages.removeAt(index));
  }

  void _finish() => Navigator.of(context).pop(_capturedImages);

  void _showFullscreenImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                // Minimal top bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Image ${index + 1} of ${_capturedImages.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),
                // Fullscreen image
                Expanded(
                  child: Center(
                    child: InteractiveViewer(
                      child: Image.file(
                        File(_capturedImages[index].path),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview full screen
          if (_controller != null && _controller!.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.previewSize!.height,
                  height: _controller!.value.previewSize!.width,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),


          // Close button top-left - native camera style
          Positioned(
            top: MediaQuery.of(context).padding.top + 40,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.4),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Bottom frosted panel with thumbnails & shutter controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    // semi-transparent so camera feed is visible
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_capturedImages.isNotEmpty)
                        Container(
                          height: 100,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemCount: _capturedImages.length,
                            itemBuilder: (_, i) => Container(
                              width: 80,
                              height: 80,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    onTap: () => _showFullscreenImage(i),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_capturedImages[i].path),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(i),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 16),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.cameraswitch,
                                color: Colors.white, size: 28),
                            onPressed: _switchCamera,
                          ),
                          GestureDetector(
                            onTap: (_isBusy || _capturedImages.length >= widget.maxImages) ? null : _captureImage,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _capturedImages.length >= widget.maxImages 
                                    ? Colors.grey.withOpacity(0.5)
                                    : _isCapturing 
                                        ? Colors.grey[300]
                                        : Colors.white,
                                border: Border.all(
                                  color: _capturedImages.length >= widget.maxImages 
                                      ? Colors.grey
                                      : Colors.white, 
                                  width: 2
                                ),
                              ),
                              child: Icon(
                                Icons.lens,
                                color: _capturedImages.length >= widget.maxImages 
                                    ? Colors.grey
                                    : Colors.black,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48), // spacer for symmetry
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating green check (done) - positioned at bottom right
          if (_capturedImages.isNotEmpty)
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: _finish,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
