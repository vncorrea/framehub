import 'package:flutter/material.dart';
import 'package:framehub/views/screens/create_post_screen.dart';
import 'feed_screen.dart'; 
import 'explore_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Lista de telas correspondentes a cada aba.
  final List<Widget> _pages = const [
    FeedScreen(),
    ExploreScreen(),
    CreatePostScreen()
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O IndexedStack mantém o estado de cada página.
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Feed",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Explorar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: "Adicionar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}