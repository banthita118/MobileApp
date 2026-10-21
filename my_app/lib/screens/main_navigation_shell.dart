import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_dashboard_screen.dart';
import 'ticket_list_screen.dart';
import 'create_ticket_screen.dart';
import 'profile_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Fetch tickets on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apiService.fetchTickets();
    });
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeDashboardScreen(onTabChange: _onTabTapped),
      const TicketListScreen(),
      CreateTicketScreen(
        onCreated: () {
          setState(() => _currentIndex = 1); // Jump to tickets list
        },
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        backgroundColor: Colors.white,
        elevation: 3,
        indicatorColor: const Color(0xFFEFF6FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF2563EB)),
            label: 'หน้าแรก',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number_rounded, color: Color(0xFF2563EB)),
            label: 'รายการแจ้ง',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box_rounded, color: Color(0xFF2563EB)),
            label: 'แจ้งปัญหา',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF2563EB)),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}
