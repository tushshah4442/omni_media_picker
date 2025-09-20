# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.1.0 - 2025-09-20
- Initial release of Omni Media Picker
- Multi

### Added
- Initial release of Omni Media Picker
- Multiple image capture functionality
- Professional camera interface with thumbnails
- Real-time image preview and deletion
- Fullscreen image viewer
- Customizable resolution settings
- Maximum image count configuration
- Smooth capture animations and feedback
- Error handling for camera initialization
- Portrait orientation lock for consistent UI
- Grid-based image display in example app
- Comprehensive documentation and examples

### Features
- 📸 Capture multiple images with configurable limit
- 🎨 Professional camera UI with modern design
- 🔄 Real-time thumbnail preview
- 🖼️ Fullscreen image viewer with zoom/pan
- ⚡ Smooth animations and user feedback
- 📱 Immersive fullscreen camera experience
- 🎯 Customizable camera resolution
- 🛡️ Robust error handling

### Technical Details
- Built with Flutter camera plugin
- Returns `List<XFile>` for captured images
- Supports Android and iOS platforms
- Requires camera permissions (handled by app)
- Uses `ResolutionPreset` for image quality control
