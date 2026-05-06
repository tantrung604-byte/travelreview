import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/firebase/firebase_providers.dart';
import '../content/travel_content.dart';
import '../tour/tour_provider.dart';
import 'admin_providers.dart';

class TourCmsScreen extends ConsumerStatefulWidget {
  const TourCmsScreen({super.key});

  @override
  ConsumerState<TourCmsScreen> createState() => _TourCmsScreenState();
}

class _TourCmsScreenState extends ConsumerState<TourCmsScreen> {
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _emojiCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _itineraryCtrl = TextEditingController();
  final _guideCtrl = TextEditingController();
  final _placesCtrl = TextEditingController();
  final _highlightsCtrl = TextEditingController(); // CSV input

  // Lịch trình theo ngày – admin có thể thêm/xóa/chỉnh sửa từng ngày
  final List<_DayCtrls> _dayCtrls = [];

  String? _selectedTourId;
  bool _saving = false;
  bool _seeding = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _ratingCtrl.dispose();
    _emojiCtrl.dispose();
    _descCtrl.dispose();
    _itineraryCtrl.dispose();
    _guideCtrl.dispose();
    _placesCtrl.dispose();
    _highlightsCtrl.dispose();
    for (final d in _dayCtrls) {
      d.dispose();
    }
    super.dispose();
  }

  // ---------------------- Actions ----------------------

  Future<void> _seedTours() async {
    setState(() => _seeding = true);
    final firestore = ref.read(firestoreProvider);
    final batch = firestore.batch();

    for (final seed in seededTours) {
      final doc = firestore.collection('tours').doc(seed.id);
      batch.set(doc, {
        'title': seed.title,
        'description': seed.description,
        'itinerary': seed.itinerary,
        'guide': seed.guide,
        'places': seed.places,
        'price': seed.price,
        'rating': seed.rating,
        'emoji': '📍',
        'highlights': const <String>[],
        'imageUrls': const <String>[],
        'updatedAt': FieldValue.serverTimestamp(),
        'seeded': true,
      }, SetOptions(merge: true));
    }

    await batch.commit();
    if (!mounted) return;
    setState(() => _seeding = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Seeded ${seededTours.length} tours to Firestore')),
    );
  }

  Future<void> _saveTour() async {
    final id = _selectedTourId;
    if (id == null || id.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref.read(tourRepositoryProvider).updateTour(id, {
        'title': _titleCtrl.text.trim(),
        'price': _priceCtrl.text.trim(),
        'rating': _ratingCtrl.text.trim().isEmpty ? '5.0' : _ratingCtrl.text.trim(),
        'emoji': _emojiCtrl.text.trim().isEmpty ? '📍' : _emojiCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'itinerary': _itineraryCtrl.text.trim(),
        'guide': _guideCtrl.text.trim(),
        'places': _placesCtrl.text.trim(),
        'highlights': _highlightsCtrl.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'scheduleItems': _dayCtrls.asMap().entries.map((e) {
          final idx = e.key;
          final d = e.value;
          final dayNum = idx + 1;
          final lbl = d.labelCtrl.text.trim();
          return {
            'day': dayNum,
            'label': lbl.isEmpty ? 'Ngày $dayNum' : lbl,
            'title': d.titleCtrl.text.trim(),
            'activities': d.activitiesCtrl.text
                .split('\n')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
            'note': d.noteCtrl.text.trim(),
          };
        }).toList(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tour content updated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _createTour() async {
    final result = await showDialog<_NewTourInput>(
      context: context,
      builder: (_) => const _NewTourDialog(),
    );
    if (result == null) return;
    try {
      final id = await ref.read(tourRepositoryProvider).createTour(
            id: result.id.isEmpty ? null : result.id,
            title: result.title,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created tour: $id')),
      );
      // Auto-load tour vừa tạo.
      _loadTourFromModel(TourModel(
        id: id,
        title: result.title,
        description: '',
        itinerary: '',
        guide: '',
        places: '',
        highlights: const [],
        imageUrls: const [],
        emoji: '📍',
        price: '',
        rating: '5.0',
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create failed: $e')),
      );
    }
  }

  Future<void> _deleteTour(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete tour?'),
        content: Text('Tour "$id" và toàn bộ ảnh trong Storage sẽ bị xóa.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(tourRepositoryProvider).deleteTour(id);
      if (!mounted) return;
      if (_selectedTourId == id) {
        setState(() => _selectedTourId = null);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted tour: $id')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  Future<void> _pickAndUploadImages() async {
    final id = _selectedTourId;
    if (id == null) return;
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;
    final bytesList = await Future.wait(files.map((f) => f.readAsBytes()));
    try {
      await ref.read(imageUploadProvider.notifier).upload(
            images: bytesList,
            tourId: id,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded ${bytesList.length} image(s)')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  Future<void> _removeImage(String url) async {
    final id = _selectedTourId;
    if (id == null) return;
    try {
      await ref.read(tourRepositoryProvider).removeTourImage(tourId: id, url: url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remove failed: $e')),
      );
    }
  }

  void _loadTourFromModel(TourModel m) {
    // Dispose và xóa các controller cũ
    for (final d in _dayCtrls) {
      d.dispose();
    }
    setState(() {
      _selectedTourId = m.id;
      _titleCtrl.text = m.title;
      _priceCtrl.text = m.price;
      _ratingCtrl.text = m.rating;
      _emojiCtrl.text = m.emoji;
      _descCtrl.text = m.description;
      _itineraryCtrl.text = m.itinerary;
      _guideCtrl.text = m.guide;
      _placesCtrl.text = m.places;
      _highlightsCtrl.text = m.highlights.join(', ');
      _dayCtrls.clear();
      for (final item in m.scheduleItems) {
        _dayCtrls.add(_DayCtrls.fromItem(item));
      }
    });
  }

  void _addDay() {
    setState(() {
      final dayNum = _dayCtrls.length + 1;
      _dayCtrls.add(_DayCtrls.empty(dayNum));
    });
  }

  void _removeDay(int index) {
    setState(() {
      _dayCtrls[index].dispose();
      _dayCtrls.removeAt(index);
    });
  }

  // ---------------------- Build ----------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toursAsync = ref.watch(adminToursStreamProvider);
    final uploadState = ref.watch(imageUploadProvider);

    // Tour hiện đang chọn (lấy snapshot mới nhất từ stream để có imageUrls cập nhật).
    final selectedTour = toursAsync.maybeWhen(
      data: (list) {
        if (_selectedTourId == null) return null;
        for (final t in list) {
          if (t.id == _selectedTourId) return t;
        }
        return null;
      },
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tours CMS'),
        actions: [
          TextButton.icon(
            onPressed: _createTour,
            icon: const Icon(Icons.add),
            label: const Text('New tour'),
          ),
          TextButton.icon(
            onPressed: _seeding ? null : _seedTours,
            icon: _seeding
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: const Text('Seed defaults'),
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 340,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: theme.dividerColor)),
            ),
            child: toursAsync.when(
              data: (tours) {
                if (tours.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No tours found. Use "Seed defaults" or "New tour".'),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: tours.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final t = tours[index];
                    final selected = t.id == _selectedTourId;
                    return ListTile(
                      selected: selected,
                      leading: Text(t.emoji, style: const TextStyle(fontSize: 24)),
                      title: Text(t.title.isEmpty ? t.id : t.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${t.price.isEmpty ? "—" : t.price}  •  ⭐ ${t.rating}  •  ${t.imageUrls.length} ảnh',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _deleteTour(t.id),
                      ),
                      onTap: () => _loadTourFromModel(t),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error loading tours: $err'),
                ),
              ),
            ),
          ),
          Expanded(
            child: _selectedTourId == null
                ? const Center(
                    child: Text('Select a tour to edit, or create a new one.'),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Editing tour: $_selectedTourId',
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: _saving ? null : _saveTour,
                              icon: _saving
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(_saving ? 'Saving...' : 'Save changes'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: _CmsField(
                                label: 'Title',
                                child: TextField(
                                  controller: _titleCtrl,
                                  maxLines: 2,
                                  decoration: const InputDecoration(
                                    hintText: 'Tour title',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: _CmsField(
                                label: 'Emoji',
                                child: TextField(
                                  controller: _emojiCtrl,
                                  decoration: const InputDecoration(
                                    hintText: '📍',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _CmsField(
                                label: 'Price',
                                child: TextField(
                                  controller: _priceCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. 1,290,000 VND',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _CmsField(
                                label: 'Rating (0–5)',
                                child: TextField(
                                  controller: _ratingCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: '4.8',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _CmsField(
                          label: 'Description',
                          child: TextField(
                            controller: _descCtrl,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'Short marketing description...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _CmsField(
                          label: 'Itinerary',
                          child: TextField(
                            controller: _itineraryCtrl,
                            minLines: 5,
                            maxLines: 8,
                            decoration: const InputDecoration(
                              hintText: 'Day-by-day itinerary...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _CmsField(
                          label: 'Guide / Tips',
                          child: TextField(
                            controller: _guideCtrl,
                            minLines: 2,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'Travel tips, what to bring, etc.',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _CmsField(
                          label: 'Places',
                          child: TextField(
                            controller: _placesCtrl,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Comma-separated place names',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _CmsField(
                          label: 'Highlights (cách nhau bởi dấu phẩy)',
                          child: TextField(
                            controller: _highlightsCtrl,
                            minLines: 2,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Cable car, Sunset view, Local food',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Lịch trình theo ngày ─────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '📅 Lịch trình chi tiết theo ngày',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _addDay,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Thêm ngày'),
                              style: FilledButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mỗi ngày: nhãn ngày, tiêu đề, hoạt động (mỗi dòng 1 hoạt động), lưu ý.',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 12),
                        if (_dayCtrls.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: theme.dividerColor,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(10),
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, size: 18),
                                SizedBox(width: 8),
                                Text('Chưa có ngày nào. Bấm "Thêm ngày" để bắt đầu.'),
                              ],
                            ),
                          )
                        else
                          for (var i = 0; i < _dayCtrls.length; i++)
                            _DayScheduleEditor(
                              index: i,
                              ctrls: _dayCtrls[i],
                              onRemove: () => _removeDay(i),
                            ),
                        const SizedBox(height: 24),
                        // ---------- Image gallery ----------
                        _ImageGallerySection(
                          imageUrls: selectedTour?.imageUrls ?? const [],
                          isUploading: uploadState.isUploading,
                          progress: uploadState.progress,
                          uploadStatus: uploadState.total == 0
                              ? null
                              : '${uploadState.completed}/${uploadState.total}',
                          onPickUpload: _pickAndUploadImages,
                          onRemove: _removeImage,
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Helpers
// ============================================================================

class _CmsField extends StatelessWidget {
  const _CmsField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ImageGallerySection extends StatelessWidget {
  const _ImageGallerySection({
    required this.imageUrls,
    required this.isUploading,
    required this.progress,
    required this.uploadStatus,
    required this.onPickUpload,
    required this.onRemove,
  });

  final List<String> imageUrls;
  final bool isUploading;
  final double progress;
  final String? uploadStatus;
  final VoidCallback onPickUpload;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_outlined),
              const SizedBox(width: 8),
              Text('Tour images (${imageUrls.length})',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: isUploading ? null : onPickUpload,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Upload'),
              ),
            ],
          ),
          if (isUploading) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: LinearProgressIndicator(value: progress)),
                const SizedBox(width: 12),
                if (uploadStatus != null) Text(uploadStatus!),
              ],
            ),
          ],
          const SizedBox(height: 12),
          if (imageUrls.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Chưa có ảnh nào. Bấm Upload để thêm.',
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (context, i) {
                final url = imageUrls[i];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(url, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton.filled(
                        icon: const Icon(Icons.close, size: 16),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(28, 28),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => onRemove(url),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// New Tour dialog
// ============================================================================

class _NewTourInput {
  const _NewTourInput({required this.id, required this.title});
  final String id;
  final String title;
}

class _NewTourDialog extends StatefulWidget {
  const _NewTourDialog();

  @override
  State<_NewTourDialog> createState() => _NewTourDialogState();
}

class _NewTourDialogState extends State<_NewTourDialog> {
  final _idCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();

  @override
  void dispose() {
    _idCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  String _slugify(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New tour'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Da Nang - Ba Na Hills 3N2D',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                if (_idCtrl.text.isEmpty) {
                  _idCtrl.text = _slugify(v);
                  _idCtrl.selection = TextSelection.collapsed(offset: _idCtrl.text.length);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _idCtrl,
              decoration: const InputDecoration(
                labelText: 'Doc ID (slug, optional)',
                hintText: 'da-nang-ba-na-hills',
                border: OutlineInputBorder(),
                helperText: 'Để trống → Firestore auto-id. Dùng slug để URL & SEO đẹp.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleCtrl.text.trim();
            if (title.isEmpty) return;
            Navigator.pop(
              context,
              _NewTourInput(id: _idCtrl.text.trim(), title: title),
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

// ============================================================================
// _DayCtrls – controller set cho một ngày trong lịch trình
// ============================================================================

class _DayCtrls {
  final TextEditingController labelCtrl;
  final TextEditingController titleCtrl;
  final TextEditingController activitiesCtrl;
  final TextEditingController noteCtrl;

  _DayCtrls({
    required this.labelCtrl,
    required this.titleCtrl,
    required this.activitiesCtrl,
    required this.noteCtrl,
  });

  factory _DayCtrls.empty(int dayNum) => _DayCtrls(
        labelCtrl: TextEditingController(text: 'Ngày $dayNum'),
        titleCtrl: TextEditingController(),
        activitiesCtrl: TextEditingController(),
        noteCtrl: TextEditingController(),
      );

  factory _DayCtrls.fromItem(DayScheduleItem item) => _DayCtrls(
        labelCtrl: TextEditingController(text: item.label),
        titleCtrl: TextEditingController(text: item.title),
        activitiesCtrl:
            TextEditingController(text: item.activities.join('\n')),
        noteCtrl: TextEditingController(text: item.note),
      );

  void dispose() {
    labelCtrl.dispose();
    titleCtrl.dispose();
    activitiesCtrl.dispose();
    noteCtrl.dispose();
  }
}

// ============================================================================
// _DayScheduleEditor – UI card cho một ngày trong CMS
// ============================================================================

class _DayScheduleEditor extends StatelessWidget {
  const _DayScheduleEditor({
    required this.index,
    required this.ctrls,
    required this.onRemove,
  });

  final int index;
  final _DayCtrls ctrls;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayNum = index + 1;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$dayNum',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ngày $dayNum',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Xóa ngày này',
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Label
            TextField(
              controller: ctrls.labelCtrl,
              decoration: const InputDecoration(
                labelText: 'Nhãn ngày',
                hintText: 'Ngày 1',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 10),

            // Title
            TextField(
              controller: ctrls.titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề ngày',
                hintText: 'Di chuyển & tham quan chợ nổi',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 10),

            // Activities
            TextField(
              controller: ctrls.activitiesCtrl,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Hoạt động (mỗi dòng 1 mục)',
                hintText:
                    '06:00 - Xuất phát từ TP.HCM\n11:00 - Đến Cần Thơ, nhận phòng\n14:00 - Tham quan chợ nổi',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 10),

            // Note
            TextField(
              controller: ctrls.noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Lưu ý (tùy chọn)',
                hintText: 'Mang theo kem chống nắng và áo mưa',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
