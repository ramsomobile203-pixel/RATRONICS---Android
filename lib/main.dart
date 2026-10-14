import 'package:flutter/material.dart';

void main() {
  runApp(const RatronicsApp());
}

class RatronicsApp extends StatelessWidget {
  const RatronicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RATRONICS',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB71C1C),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> departments = [
    'RAMSO MOBILE SHOP',
    'RAMSO DIGITAL',
    'RAMSO ELECTRONICS',
    'RAMSO SERVICE CENTER',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        title: const Text(
          'RATRONICS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'KARIBU RATRONICS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chagua kitengo unachohitaji',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...departments.map(
              (department) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(
                      Icons.store,
                      color: Color(0xFFB71C1C),
                    ),
                    title: Text(
                      department,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '$department itafunguliwa baada ya hatua '
                            'za ujenzi zinazofuata.',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
