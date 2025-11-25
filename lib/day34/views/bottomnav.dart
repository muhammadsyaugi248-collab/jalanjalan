import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:jalanjalan/day34/views/absensi/absensi.dart';
import 'package:jalanjalan/day34/views/dashboard_screen.dart';
import 'package:jalanjalan/day34/views/history/history_screen.dart';
import 'package:jalanjalan/day34/views/profils/profile_screen.dart';
import 'package:jalanjalan/day34/views/settin/setting.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  int _index = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    DashboardScreen(),
    HomeScreen(),
    HistoryScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavSelect(int index) {
    // Jika index sama, tidak perlu apa-apa
    if (index == _index) return;

    // Tunda perubahan hingga frame saat ini selesai -> mencegah setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // lakukan animate dulu (opsional) lalu update state
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() {
        _index = index;
      });
    });

    // Alternatif singkat:
    // Future.microtask(() {
    //   if (!mounted) return;
    //   _pageController.animateToPage(index, duration: Duration(milliseconds:300), curve: Curves.easeOut);
    //   setState(() => _index = index);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (value) {
          // onPageChanged dipanggil saat geser; aman dipanggil langsung
          setState(() {
            _index = value;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomBarBubble(
        selectedIndex: _index,
        items: [
          BottomBarItem(iconData: Icons.home),
          BottomBarItem(iconData: Icons.date_range),
          BottomBarItem(iconData: Icons.history),
          BottomBarItem(iconData: Icons.person),
          BottomBarItem(iconData: Icons.settings),
        ],
        backgroundColor: Colors.white,
        color: Colors.black,
        onSelect: _onNavSelect,
      ),
    );
  }
}
