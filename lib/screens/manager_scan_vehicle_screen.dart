import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_app/widgets/bottom_navigation_bar.dart';
import 'manager_vehicles_list_screen.dart';
import 'manager_history_screen.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ManagerScanVehicleScreen extends StatefulWidget {
  const ManagerScanVehicleScreen({Key? key}) : super(key: key);

  @override
  _ManagerScanVehicleScreenState createState() => _ManagerScanVehicleScreenState();
}

class _ManagerScanVehicleScreenState extends State<ManagerScanVehicleScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  XFile? _carPhoto;
  XFile? _licensePlatePhoto;
  bool _isTakingCarPhoto = true;
  bool _useCamera = true; // New state to toggle between camera and manual input
  final TextEditingController _manualLicensePlateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(_cameras![0], ResolutionPreset.medium);
        await _controller!.initialize();
        if (!mounted) {
          return;
        }
        setState(() {});
      }
    } catch (e) {
      print('Error initializing camera: $e');
      // If camera fails, default to manual input
      if (mounted) {
        setState(() {
          _useCamera = false;
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final image = await _controller!.takePicture();
      if (_isTakingCarPhoto) {
        setState(() {
          _carPhoto = image;
          _isTakingCarPhoto = false;
        });
      } else {
        setState(() {
          _licensePlatePhoto = image;
        });

        final textRecognizer = TextRecognizer();
        final inputImage = InputImage.fromFilePath(_licensePlatePhoto!.path);
        final recognizedText = await textRecognizer.processImage(inputImage);
        await textRecognizer.close();

        String licensePlate = '';
        RegExp plateRegex = RegExp(r'[A-Z0-9]{5,10}');
        for (TextBlock block in recognizedText.blocks) {
          for (TextLine line in block.lines) {
            for (TextElement element in line.elements) {
              if (plateRegex.hasMatch(element.text)) {
                licensePlate = element.text;
                break;
              }
            }
            if (licensePlate.isNotEmpty) break;
          }
          if (licensePlate.isNotEmpty) break;
        }

        if (licensePlate.isNotEmpty) {
          await _createVehicleEntry(licensePlate, _carPhoto, _licensePlatePhoto);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось распознать номер машины. Попробуйте еще раз.')),
          );
          setState(() {
            _carPhoto = null;
            _licensePlatePhoto = null;
            _isTakingCarPhoto = true;
          });
        }
      }
    } catch (e) {
      print('Error taking photo or processing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Произошла ошибка: ${e.toString()}')),
        );
        setState(() {
          _carPhoto = null;
          _licensePlatePhoto = null;
          _isTakingCarPhoto = true;
        });
      }
    }
  }

  Future<void> _manualEntry() async {
    String licensePlate = _manualLicensePlateController.text.trim();
    if (licensePlate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите номер машины')),
      );
      return;
    }
    await _createVehicleEntry(licensePlate, null, null); // No photos for manual entry
  }

  Future<void> _createVehicleEntry(String licensePlate, XFile? carPhoto, XFile? licensePlatePhoto) async {
    try {
      String? carPhotoUrl;
      String? licensePlatePhotoUrl;

      if (carPhoto != null) {
        carPhotoUrl = await _uploadPhoto(carPhoto, 'car_photos');
      }
      if (licensePlatePhoto != null) {
        licensePlatePhotoUrl = await _uploadPhoto(licensePlatePhoto, 'license_plate_photos');
      }

      await FirebaseFirestore.instance.collection('vehicles').add({
        'licensePlate': licensePlate,
        'photoUrl': carPhotoUrl,
        'licensePlatePhotoUrl': licensePlatePhotoUrl,
        'status': 'active',
        'entryTime': FieldValue.serverTimestamp(),
        'exitTime': null,
        'totalTime': 0,
        'managerId': FirebaseAuth.instance.currentUser!.uid,
        'items': [],
        'totalAmount': 0,
        'paymentMethod': null,
        'paymentStatus': 'pending',
        'adminComment': null,
        'adminId': null,
      });

      final String? currentManagerId = FirebaseAuth.instance.currentUser?.uid;
      if (currentManagerId != null && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ManagerVehiclesListScreen(managerId: currentManagerId)),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось получить ID менеджера для навигации.')),
        );
      }
    } catch (e) {
      print('Error creating vehicle entry: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Произошла ошибка при создании записи: ${e.toString()}')),
        );
      }
    }
  }

  Future<String> _uploadPhoto(XFile photo, String folder) async {
    try {
      File file = File(photo.path);
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${photo.name}';
      Reference storageRef = FirebaseStorage.instance.ref().child('$folder/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading photo: $e');
      throw e;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _manualLicensePlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканировать Машину'),
        actions: [
          IconButton(
            icon: Icon(_useCamera ? Icons.text_fields : Icons.camera_alt),
            onPressed: () {
              setState(() {
                _useCamera = !_useCamera;
                _carPhoto = null; // Reset photos when switching mode
                _licensePlatePhoto = null;
                _isTakingCarPhoto = true;
                _manualLicensePlateController.clear();
              });
            },
          ),
        ],
      ),
      body: _useCamera
          ? (_controller == null || !_controller!.value.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(child: CameraPreview(_controller!)),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _takePhoto,
                        child: Text(_isTakingCarPhoto ? 'Сделать фото машины' : 'Сделать фото номера'),
                      ),
                    ),
                  ],
                ))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _manualLicensePlateController,
                    decoration: const InputDecoration(
                      labelText: 'Номер машины',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _manualEntry,
                    child: const Text('Добавить машину вручную'),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: ManagerBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          final String? currentManagerId = FirebaseAuth.instance.currentUser?.uid;
          if (currentManagerId == null) {
            if (mounted) { // Ensure 'mounted' is accessible or use 'context.mounted' if in a builder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Не удалось получить ID менеджера для навигации.')),
              );
            }
            return;
          }

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ManagerVehiclesListScreen(managerId: currentManagerId)),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ManagerHistoryScreen(managerId: currentManagerId)),
            );
          }
        },
      ),
    );
  }
}
