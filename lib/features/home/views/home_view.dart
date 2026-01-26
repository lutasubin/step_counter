import 'package:flutter/material.dart';

/// Màn hình home
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WalkFit - Step Counter'),
      ),
      body: const Center(
        child: Text('Home Screen'),
      ),
    );
  }
}
