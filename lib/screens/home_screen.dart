import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/hostels'),
              child: const Text('View Hostels'),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () => context.go('/cancel-demo'),
              child: const Text('Cancel Reservation Demo'),
            ),
          ],
        ),
      ),
    );
  }
}
