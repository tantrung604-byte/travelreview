import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/firebase/firebase_providers.dart';
import 'dart:typed_data';

class ImageUploadManagerScreen extends ConsumerStatefulWidget {
  const ImageUploadManagerScreen({super.key});

  @override
  ConsumerState<ImageUploadManagerScreen> createState() => _ImageUploadManagerScreenState();
}

class _ImageUploadManagerScreenState extends ConsumerState<ImageUploadManagerScreen> {
  final List<Uint8List> _selectedImages = [];
  bool _isUploading = false;
  String? _statusMessage;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      final bytesList = await Future.wait(images.map((img) => img.readAsBytes()));
      setState(() {
        _selectedImages.addAll(bytesList);
      });
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isUploading = true;
      _statusMessage = 'Đang tải lên ${_selectedImages.length} ảnh...';
    });

    try {
      final storage = ref.read(firebaseStorageProvider);
      final List<String> downloadUrls = [];

      for (var i = 0; i < _selectedImages.length; i++) {
        final fileName = 'admin_upload_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final ref = storage.ref().child('tours/images/$fileName');

        // Upload bytes (hỗ trợ Web tốt nhất)
        final uploadTask = await ref.putData(
          _selectedImages[i],
          SettableMetadata(contentType: 'image/jpeg'),
        );

        final url = await uploadTask.ref.getDownloadURL();
        downloadUrls.add(url);
      }

      setState(() {
        _isUploading = false;
        _statusMessage = 'Thành công! Đã tải lên ${downloadUrls.length} ảnh.';
        _selectedImages.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tải ảnh lên thành công!')),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage = 'Lỗi: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Upload Hình Ảnh'),
        actions: [
          if (_selectedImages.isNotEmpty && !_isUploading)
            TextButton.icon(
              onPressed: _uploadImages,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Tải lên ngay'),
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn hình ảnh cho các Tour & Vùng du lịch',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Hình ảnh sau khi tải lên sẽ có link URL để bạn gắn vào bài viết review và hướng dẫn.',
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),
            if (_statusMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _statusMessage!.contains('Lỗi')
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusMessage!.contains('Lỗi') ? Colors.red : Colors.green
                  ),
                ),
                child: Text(_statusMessage!, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),

            Expanded(
              child: _selectedImages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.image_search),
                            label: const Text('Chọn ảnh từ máy tính'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _selectedImages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _selectedImages.length) {
                          return InkWell(
                            onTap: _pickImages,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add, size: 40),
                            ),
                          );
                        }
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                _selectedImages[index],
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton.filled(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () => setState(() => _selectedImages.removeAt(index)),
                                color: Colors.white,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            if (_isUploading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: LinearProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
