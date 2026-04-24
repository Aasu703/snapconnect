import 'package:flutter/material.dart';

/// Bottom navigation used across shell routes.
class AppNavbar extends StatelessWidget {
  const AppNavbar({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_album_outlined),
          activeIcon: Icon(Icons.photo_album),
          label: 'Albums',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.celebration_outlined),
          activeIcon: Icon(Icons.celebration),
          label: 'Parties',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_a_photo_outlined),
          activeIcon: Icon(Icons.add_a_photo),
          label: 'Upload',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF4D96FF),
      unselectedItemColor: Colors.grey,
      onTap: onTap,
    );
  }
}
