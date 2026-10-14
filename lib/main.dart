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

  static const departments = [
    {
      'title': 'RAMSO MOBILE SHOP',
      'subtitle': 'Smartphones na accessories',
      'icon': Icons.phone_android,
    },
    {
      'title': 'RAMSO DIGITAL',
      'subtitle': 'Huduma za kidijitali',
      'icon': Icons.devices,
    },
    {
      'title': 'RAMSO ELECTRONICS',
      'subtitle': 'Vifaa vya kielektroniki',
      'icon': Icons.electrical_services,
    },
    {
      'title': 'RAMSO SERVICE CENTER',
      'subtitle': 'Huduma na matengenezo',
      'icon': Icons.build,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'RATRONICS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 15),
          const Icon(
            Icons.business,
            size: 65,
            color: Color(0xFFB71C1C),
          ),
          const SizedBox(height: 12),
          const Text(
            'KARIBU RATRONICS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'RAMSO Business Services',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 25),
          const Text(
            'CHAGUA KITENGO',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...departments.map((department) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 14),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Icon(
                  department['icon'] as IconData,
                  color: const Color(0xFFB71C1C),
                  size: 32,
                ),
                title: Text(
                  department['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  department['subtitle'] as String,
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DepartmentScreen(
                        title: department['title'] as String,
                        subtitle: department['subtitle'] as String,
                        icon: department['icon'] as IconData,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class DepartmentScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const DepartmentScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 80,
                color: const Color(0xFFB71C1C),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Karibu kwenye kitengo chako cha RATRONICS.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('RUDI NYUMA'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
