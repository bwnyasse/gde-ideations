import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CameraService {
  CameraController? _controller;
  bool _isInitialized = false;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) throw Exception('No cameras available');
    
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
    _isInitialized = true;
  }

  Future<String> captureImage() async {
    if (!_isInitialized) throw Exception('Camera not initialized');
    
    final XFile image = await _controller!.takePicture();
    final directory = await getTemporaryDirectory();
    final String filePath = '${directory.path}/${DateTime.now().toIso8601String()}.jpg';
    
    await image.saveTo(filePath);
    return filePath;
  }

  void dispose() {
    _controller?.dispose();
    _isInitialized = false;
  }

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;
}