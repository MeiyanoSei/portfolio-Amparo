import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_service.dart';
import 'authentication_Service.dart';
import 'theme_provider.dart';

// Model class for drawer items
class DrawerItem {
  final IconData icon;
  final String title;
  final String category;

  DrawerItem({
    required this.icon,
    required this.title,
    required this.category,
  });
}

class CustomDrawer extends StatefulWidget {
  final String userId;
  const CustomDrawer({super.key, required this.userId});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late FirebaseService _firebaseService;
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController _drawerSearchController = TextEditingController();
  final AuthService _authService = AuthService();
  User? currentUser;

  double _fontSizeMultiplier = 1.0;
  bool _notificationsEnabled = true;

  List<DrawerItem> _filteredItems = [];

  // Define all drawer menu items
  final List<DrawerItem> _allDrawerItems = [
    DrawerItem(icon: Icons.person, title: 'Account', category: 'menu'),
    DrawerItem(icon: Icons.settings, title: 'Settings', category: 'menu'),
    DrawerItem(icon: Icons.security, title: 'Privacy and Security', category: 'settings'),
    DrawerItem(icon: Icons.lock, title: 'Permissions', category: 'settings'),
    DrawerItem(icon: Icons.tune, title: 'Additional Settings', category: 'settings'),
    DrawerItem(icon: Icons.accessibility, title: 'Accessibility', category: 'menu'),
    DrawerItem(icon: Icons.dark_mode, title: 'Dark Mode', category: 'accessibility'),
    DrawerItem(icon: Icons.text_fields, title: 'Font Size', category: 'accessibility'),
    DrawerItem(icon: Icons.account_balance_wallet, title: 'Wallet', category: 'menu'),
    DrawerItem(icon: Icons.notifications, title: 'Notifications', category: 'menu'),
    DrawerItem(icon: Icons.logout, title: 'Sign Out', category: 'footer'),
    DrawerItem(icon: Icons.info_outline, title: 'About Us', category: 'footer'),
  ];

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService(userId: widget.userId);
    currentUser = FirebaseAuth.instance.currentUser;
    _filteredItems = _allDrawerItems;
    _loadSettings();

    _drawerSearchController.addListener(_filterDrawerItems);
  }

  Future<void> _loadSettings() async {
    // Load font size and notification preferences from SharedPreferences or Firestore
    // For now, using default values
  }

  void _filterDrawerItems() {
    final query = _drawerSearchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allDrawerItems;
      } else {
        _filteredItems = _allDrawerItems
            .where((item) => item.title.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    balanceController.dispose();
    _drawerSearchController.dispose();
    super.dispose();
  }

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Profile section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: currentUser?.photoURL != null
                        ? NetworkImage(currentUser!.photoURL!)
                        : const AssetImage('assets/img_1.png') as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentUser?.displayName ?? 'User',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    currentUser?.email ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Search bar for drawer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _drawerSearchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _drawerSearchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () => _drawerSearchController.clear(),
                            child: const Icon(Icons.close, size: 20),
                          )
                        : null,
                    hintText: 'Search drawer...',
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Display filtered drawer items
            if (_filteredItems.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No results found',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              )
            else
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: const Color.fromARGB(0, 255, 255, 255),
                  splashColor: const Color.fromARGB(255, 199, 199, 199),
                  expansionTileTheme: const ExpansionTileThemeData(
                    backgroundColor: Colors.transparent,
                    collapsedBackgroundColor: Colors.transparent,
                    iconColor: Colors.black,
                    collapsedIconColor: Colors.black,
                  ),
                ),
                child: Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];

                      if (item.title == 'Account') {
                        return _buildDrawerItem(
                            item.icon, item.title, context);
                      } else if (item.title == 'Settings') {
                        return _buildSettingsExpansion();
                      } else if (item.title == 'Accessibility') {
                        return _buildAccessibilityExpansion();
                      } else if (item.title == 'Wallet') {
                        return _buildWalletExpansion();
                      } else if (item.title == 'Notifications') {
                        return _buildNotificationsExpansion();
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),

            // Footer
            if (_drawerSearchController.text.isEmpty)
              Column(
                children: [
                  Divider(color: Colors.grey[300]),
                  ListTile(
                    leading:
                        const Icon(Icons.logout, size: 22, color: Colors.red),
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    ),
                    onTap: _handleSignOut,
                  ),
                  _buildDrawerItem(
                      Icons.info_outline, 'About Us', context),
                  const SizedBox(height: 20),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsExpansion() {
    return ExpansionTile(
      leading: const Icon(Icons.settings, size: 22),
      title: const Text("Settings"),
      children: [
        _buildSettingsOption('Permissions'),
        _buildSettingsOption('Privacy and Security'),
        _buildSettingsOption('Additional Settings'),
      ],
    );
  }

  Widget _buildAccessibilityExpansion() {
    return ExpansionTile(
      leading: const Icon(Icons.accessibility, size: 22),
      title: const Text("Accessibility"),
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dark Mode Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                        activeColor: const Color.fromARGB(255, 0, 0, 0),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Font Size Slider
              const Text(
                'Font Size',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('A', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: _fontSizeMultiplier,
                      min: 0.8,
                      max: 1.4,
                      divisions: 6,
                      label: _fontSizeMultiplier.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _fontSizeMultiplier = value;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Font size set to ${(_fontSizeMultiplier * 100).toStringAsFixed(0)}%',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                  const Text('A', style: TextStyle(fontSize: 20)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletExpansion() {
    return ExpansionTile(
      leading: const Icon(Icons.account_balance_wallet, size: 22),
      title: const Text("Wallet"),
      children: [
        StreamBuilder<double>(
          stream: _firebaseService.getBalanceStream(),
          builder: (context, snapshot) {
            final currentBalance = snapshot.data ?? 0.0;
            return Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(
                    'Current Balance: ₱${currentBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: balanceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Enter Amount',
                      border: OutlineInputBorder(
                        
                        borderRadius: BorderRadius.circular(20),
                      ),
                      prefixText: '₱',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final amount =
                              double.tryParse(balanceController.text);
                          if (amount != null && amount > 0) {
                            await _firebaseService.addToBalance(amount);
                            balanceController.clear();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Added ₱${amount.toStringAsFixed(2)}')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          backgroundColor: const Color.fromARGB(255, 0, 145, 48),
                          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final amount =
                              double.tryParse(balanceController.text);
                          if (amount != null && amount >= 0) {
                            await _firebaseService.updateBalance(amount);
                            balanceController.clear();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Balance set to ₱${amount.toStringAsFixed(2)}')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text("Set"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsExpansion() {
    return ExpansionTile(
      leading: const Icon(Icons.notifications, size: 22),
      title: const Text("Notifications"),
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enable Notifications',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _notificationsEnabled
                                ? 'Notifications enabled'
                                : 'Notifications disabled',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                      // TODO: Save to Firestore or SharedPreferences
                    },
                    activeColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _notificationsEnabled
                    ? 'You will receive app notifications'
                    : 'All notifications are disabled',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsOption(String title) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 40, right: 16),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13),
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title clicked')),
        );
        // Add navigation or functionality here
      },
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22, color: const Color.fromARGB(255, 0, 0, 0)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}