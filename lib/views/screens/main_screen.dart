import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';
import 'camera_screen.dart';
import 'explore_screen.dart';
import '../../models/user_model.dart';

class MainScreen extends StatefulWidget {
  final AppUser user;

  const MainScreen({Key? key, required this.user}) : super(key: key);
  
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    // Defina suas páginas. A ProfileScreen recebe o userId como parâmetro.
    final List<Widget> pages = [
      FeedScreen(),
      ExploreScreen(),
      CameraScreen(userId: widget.user.id),
      ProfileScreen(userId: widget.user.id),
    ];
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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