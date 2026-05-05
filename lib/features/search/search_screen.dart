import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm tour')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Đà Nẵng, Sapa, Phú Quốc...',
            ),
          ),
          const SizedBox(height: 20),
          const Text('Gợi ý nhanh', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final item in const ['Đà Nẵng', 'Sapa', 'Phú Quốc', 'Đà Lạt'])
            ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(item),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/discover'),
            ),
        ],
      ),
    );
  }
}

