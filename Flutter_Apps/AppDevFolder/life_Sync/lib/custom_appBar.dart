import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? hintText;
  final String userId;

  const CustomAppBar({
    super.key,
    this.hintText,
    required this.userId,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController _searchController = TextEditingController();
  late FirebaseService _firebaseService;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService(userId: widget.userId);
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Search tasks
      final tasksSnap = await _firebaseService.searchTasks(query);
      final tasks = tasksSnap.map((doc) => {
        'type': 'Task',
        'title': doc['name'] ?? 'Unnamed',
        'description': doc['description'] ?? '',
        'id': doc['id'],
        'urgency': doc['urgency'] ?? 'Normal',
      }).toList();

      // Search finance items
      final financeSnap = await _firebaseService.searchFinance(query);
      final finance = financeSnap.map((doc) => {
        'type': 'Expense',
        'title': doc['title'] ?? doc['name'] ?? 'Unnamed',
        'description': '₱${(doc['amount'] ?? 0.0).toStringAsFixed(2)}',
        'id': doc['id'],
        'isPaid': doc['isPaid'] ?? false,
      }).toList();

      // Search events
      final eventsSnap = await _firebaseService.searchEvents(query);
      final events = eventsSnap.map((doc) => {
        'type': 'Event',
        'title': doc['title'] ?? 'Unnamed',
        'description': doc['type'] ?? 'General',
        'id': doc['id'],
      }).toList();

      setState(() {
        _searchResults = [...tasks, ...finance, ...events];
        _isSearching = false;
      });

      // Show search results in modal if not empty
      if (_searchResults.isNotEmpty) {
        _showSearchResultsModal();
      }
    } catch (e) {
      print('Search error: $e');
      setState(() => _isSearching = false);
    }
  }

  void _showSearchResultsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Found ${_searchResults.length} results',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  final type = result['type'] as String;
                  return ListTile(
                    leading: Icon(
                      _getTypeIcon(type),
                      color: _getTypeColor(type),
                    ),
                    title: Text(result['title']),
                    subtitle: Text(result['description']),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 10,
                          color: _getTypeColor(type),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opened: ${result['title']}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Task':
        return Colors.blue;
      case 'Expense':
        return Colors.red;
      case 'Event':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Task':
        return Icons.checklist;
      case 'Expense':
        return Icons.money;
      case 'Event':
        return Icons.event;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              backgroundImage: currentUser?.photoURL != null
                  ? NetworkImage(currentUser!.photoURL!)
                  : null,
              child: currentUser?.photoURL == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
        ),
      ),
      title: Container(
        width: 220,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchResults = []);
                    },
                  )
                : null,
            hintText: widget.hintText ?? 'Search...',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
          ),
          onChanged: _performSearch,
        ),
      ),
    );
  }
}