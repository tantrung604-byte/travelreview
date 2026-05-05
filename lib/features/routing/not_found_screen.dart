import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Không tìm thấy trang')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.travel_explore, size: 80),
              const SizedBox(height: 16),
              Text('Route không tồn tại:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SelectableText(location),
              const SizedBox(height: 20),
              FilledButton(onPressed: () => context.go('/'), child: const Text('Về trang chủ')),
            ],
          ),
        ),
      ),
    );
  }
}

