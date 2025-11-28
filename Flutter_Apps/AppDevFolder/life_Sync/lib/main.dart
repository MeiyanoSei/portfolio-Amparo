
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:listtest/todo_Page.dart';
import 'package:listtest/home_Page.dart';
import 'package:listtest/finance_Page.dart';
import 'package:listtest/calendar_Page.dart';
import 'package:listtest/login_Page.dart';
import 'firebase_options.dart';
import 'custom_appBar.dart';
import 'custom_Drawer.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasData && snapshot.data != null) {
                return MainPage(userId: snapshot.data!.uid);
              }
              return const LoginPage();
            },
          ),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  final String userId;
  const MainPage({super.key, required this.userId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomePage(userId: widget.userId),
      FinancePage(userId: widget.userId),
      TodoPage(userId: widget.userId),
      CalendarPage(userId: widget.userId),
    ];
  }

  final items = <Widget>[
    const Icon(Icons.home, size: 30),
    const Icon(Icons.account_balance_wallet, size: 30),
    const Icon(Icons.checklist_rtl, size: 30),
    const Icon(Icons.calendar_today, size: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      drawer: CustomDrawer(userId: widget.userId),
      appBar: CustomAppBar(
        hintText: 'Search',
        userId: widget.userId,
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return CupertinoPageTransition(
                primaryRouteAnimation: animation,
                secondaryRouteAnimation: const AlwaysStoppedAnimation(0.0),
                linearTransition: false,
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey(index),
              child: pages[index],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,

              
              child: CurvedNavigationBar(
              index: index,
              items: items,
              height: 60,
              color: const Color.fromARGB(255, 192, 192, 192),
              backgroundColor: Colors.transparent,
              animationDuration: const Duration(milliseconds: 300),
              onTap: (i) => setState(() => index = i),
             ),
       
          ),
        ],
      ),
    );
  }
}