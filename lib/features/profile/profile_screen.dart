import 'package:flutter/material.dart';
import 'package:trimly/core/enums/country.dart';
import 'package:trimly/features/shared/trimly_components.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      backgroundColor: const Color(0xFFF5F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TrimlyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Country.india.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TrimlyButton(
                label: 'Manage account',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
