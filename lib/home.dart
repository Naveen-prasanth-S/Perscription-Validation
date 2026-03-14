import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'login_page.dart';
import 'verify_page.dart';
import 'screens/prescription_history_page.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  final AuthService _auth = AuthService();
  bool _alertShown = false;

  // ✅ ADDED (COMMON HISTORY NAVIGATION)
  void _openHistory() {
    final user = FirebaseAuth.instance.currentUser;
    print("CURRENT USER UID: ${user?.uid}");

    if (user == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrescriptionHistoryPage(
          userId: user.uid,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        widget.username.isNotEmpty ? widget.username : "User";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_alertShown) {
        _alertShown = true;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Welcome!"),
            content: Text("Hello $displayName 👋"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xffeef2f6),

      // ---------------- DRAWER ----------------
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person, size: 36),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Welcome",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text(displayName,
                            style:
                                const TextStyle(color: Colors.black54)),
                      ],
                    )
                  ],
                ),
              ),
              tracedMenu(Icons.home_outlined, "Home",
                  onTap: () => Navigator.pop(context)),
              tracedMenu(Icons.receipt_long, "History",
                  onTap: _openHistory), // ✅ ADDED
              tracedMenu(Icons.person_outline, "My Profile"),
              tracedMenu(Icons.notifications_none, "Notifications"),
              tracedMenu(Icons.help_outline, "Help & Support Team"),
              tracedMenu(Icons.description_outlined, "Terms of Services"),
              tracedMenu(Icons.logout, "Logout", onTap: _logout),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text("Version 2.2.6",
                    style: TextStyle(color: Colors.black45)),
              ),
            ],
          ),
        ),
      ),

      // ---------------- BODY ----------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () =>
                            Scaffold.of(context).openDrawer(),
                        child: const Icon(Icons.menu,
                            color: Colors.white, size: 28),
                      ),
                    ),
                    const Text("Dashboard",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const Icon(Icons.notifications_none,
                        color: Colors.white, size: 26),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text("Quick Actions",
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  quickAction(
                    "Verify",
                    Icons.qr_code_scanner,
                    Colors.indigo,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NewRequestPage()),
                      );
                    },
                  ),
                  quickAction(
                    "Videos",
                    Icons.video_library,
                    Colors.orange,
                  ),
                  quickAction(
                    "History",
                    Icons.receipt_long,
                    Colors.red,
                    onTap: _openHistory, // ✅ FIXED
                  ),
                  quickAction(
                    "Profile",
                    Icons.person,
                    Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text("Featured Program",
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18)),
                child: Row(
                  children: const [
                    Icon(Icons.local_hospital,
                        size: 42, color: Colors.blue),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Post-Surgery Recovery\nDaily videos & doctor-approved plans.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text("Categories",
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),

              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    categoryCard(
                        icon: Icons.favorite,
                        title: "Cardio",
                        color: Colors.red),
                    categoryCard(
                        icon: Icons.psychology,
                        title: "Brain",
                        color: Colors.purple),
                    categoryCard(
                        icon: Icons.air,
                        title: "Lungs",
                        color: Colors.blue),
                    categoryCard(
                        icon: Icons.medical_services,
                        title: "Cancer",
                        color: Colors.teal),
                    categoryCard(
                        icon: Icons.monitor_heart,
                        title: "Endo",
                        color: Colors.indigo),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ---------------- BOTTOM NAV ----------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          if (i == 2) _openHistory(); // ✅ CLEAN
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_fill), label: "Videos"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget quickAction(String title, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 6),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

Widget categoryCard({
  required IconData icon,
  required String title,
  required Color color,
}) {
  return Container(
    width: 110,
    margin: const EdgeInsets.only(right: 14),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 36, color: color),
        const SizedBox(height: 10),
        Text(
          title,
          style:
              TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

Widget tracedMenu(IconData icon, String title, {VoidCallback? onTap}) {
  return ListTile(
    leading: Icon(icon, size: 26),
    title: Text(title),
    onTap: onTap,
  );
}
