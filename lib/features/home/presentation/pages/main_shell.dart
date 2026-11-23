import 'package:flutter/material.dart';
import 'package:skinsense/features/history/presentation/pages/history_page.dart';
import 'package:skinsense/features/home/presentation/pages/home_page.dart';
import 'package:skinsense/features/scan/presentation/pages/scan_page.dart';
import 'package:skinsense/features/settings/presentation/pages/settings_page.dart';

/// Navigasi bawah: Beranda, Scan, Riwayat, Profil/Pengaturan.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(onScanTap: () => _go(1)),
          const ScanPage(),
          HistoryPage(onScanTap: () => _go(1)),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.center_focus_strong_outlined), selectedIcon: Icon(Icons.center_focus_strong), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
