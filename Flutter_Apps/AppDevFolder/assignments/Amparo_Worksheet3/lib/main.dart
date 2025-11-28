import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matt Arnel V. Amparo',
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ProfilePage(),
    const AboutPage(),
    const ContactPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
          BottomNavigationBarItem(icon: Icon(Icons.contact_mail), label: 'Contact'),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Matt Arnel Amparo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/Banger.jpg'),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Matt Arnel Amparo",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Information Section
            const Text("Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            infoRow(Icons.school, "COURSE", "BS Computer Science"),
            infoRow(Icons.email, "EMAIL", "mattarnel.amparo@wvsu.edu.ph"),
            infoRow(Icons.location_on, "ADDRESS", "Brgy. Lapayon, Leganes, Iloilo"),
            infoRow(Icons.favorite, "HOBBIES", "Coding, Drawing, Games"),
            infoRow(Icons.phone, "CONTACT", "0963 946 6185"),
            const SizedBox(height: 20),

            // Biography Section
            const Text("My Biography",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "I am a passionate Computer Science student who loves learning about coding."
              "I also like to daw a lot to hone my skills. "
              "I enjoy coding, solving problems, and continuously improving my skills.",
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Me")),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "I am currently 21 years old currently focusing on my coding ability and art skills."
            "In the future, I aim to become a proficient software developer and digital artist, and maybe make a game as a solo dev.",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.mail, size: 40, color: Colors.blue),
            SizedBox(height: 10),
            Text("mattarnel.amparo@wvsu.edu.ph"),
            SizedBox(height: 10),
            Text("Matt Arnel Amparo on Facebook"),
            SizedBox(height: 10),
            Text("0963 946 6185"),
            SizedBox(height: 10),
            Text("Bleachkreig on Instagram"),
          ],
        ),
      ),
    );
  }
}
