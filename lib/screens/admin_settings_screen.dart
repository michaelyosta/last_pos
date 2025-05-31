import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_app/models/app_settings.dart';
import 'package:pos_app/core/constants.dart'; // Import constants

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  _AdminSettingsScreenState createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final TextEditingController _priceController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _settingsDocId = FirestoreDocuments.globalSettings; // Use constant

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      DocumentSnapshot doc = await _firestore.collection(FirestoreCollections.settings).doc(_settingsDocId).get(); // Use constant
      if (doc.exists) {
        AppSettings settings = AppSettings.fromFirestore(doc);
        _priceController.text = settings.pricePerMinute.toString();
      } else {
        // If document doesn't exist, create it with a default value
        await _firestore.collection(FirestoreCollections.settings).doc(_settingsDocId).set({ // Use constant
          'pricePerMinute': 0.0,
        });
        _priceController.text = '0.0';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки настроек: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveSettings() async {
    final String priceText = _priceController.text.trim();
    if (priceText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Цена не может быть пустой.')),
        );
      }
      return;
    }

    double? newPrice = double.tryParse(priceText);

    if (newPrice == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Неверный формат цены. Пожалуйста, введите корректное число.')),
        );
      }
      return;
    }

    try {
      await _firestore.collection(FirestoreCollections.settings).doc(_settingsDocId).update({ // Use constant
        'pricePerMinute': newPrice,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Настройки сохранены успешно!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения настроек: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки Администратора'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Цена за минуту стоянки (тнг):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Введите цену за минуту',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('СОХРАНИТЬ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}
