// Flutter
import 'package:flutter/material.dart';

// Files
import 'package:home_wall/home/mainpage.dart';
import 'package:home_wall/walls/wallspage.dart';

class BuildApp extends StatefulWidget {
  const BuildApp({Key? key}) : super(key: key);

  @override
  State<BuildApp> createState() => _BuildApp();
}

class _BuildApp extends State<BuildApp> {
  int selectedPageIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MainPage(),
    WallPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeWall'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: _widgetOptions.elementAt(selectedPageIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Walls',
          ),
        ],
        currentIndex: selectedPageIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }
}
