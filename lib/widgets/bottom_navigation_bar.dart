import 'package:flutter/material.dart';

class ManagerBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ManagerBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'Выбор машины',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          label: 'Сканировать',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'История',
        ),
      ],
    );
  }
}
