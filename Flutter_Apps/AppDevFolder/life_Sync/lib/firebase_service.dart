import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_file.dart';

class FirebaseService {
  final String userId;
  late final FirebaseFirestore _db;

  FirebaseService({required this.userId}) {
    _db = FirebaseFirestore.instance;
  }

  // TASKS
  Future<void> addTask(Map<String, dynamic> task) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .add({
            'name': task['name'],
            'urgency': task['urgency'],
            'completed': task['completed'] ?? false,
            'deadline': task['deadline'] is DateTime
                ? Timestamp.fromDate(task['deadline'])
                : Timestamp.now(),
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getTasksStream() {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('deadline')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) {
              final data = d.data();
              return {
                'id': d.id,
                'name': data['name'] ?? '',
                'urgency': data['urgency'] ?? 'Normal',
                'completed': data['completed'] ?? false,
                'deadline': (data['deadline'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
              };
            })
            .toList());
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    try {
      final updateData = {...data};
      if (data['deadline'] is DateTime) {
        updateData['deadline'] = Timestamp.fromDate(data['deadline']);
      }
      await _db
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .update(updateData);
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  // FINANCE
  Future<void> addFinance(Map<String, dynamic> item) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('finance')
          .add({
            'title': item['title'] ?? '',
            'description': item['description'] ?? '',
            'amount': (item['amount'] ?? 0.0).toDouble(),
            'isPaid': item['isPaid'] ?? false,
            'createDate': item['createDate'] is DateTime
                ? Timestamp.fromDate(item['createDate'])
                : FieldValue.serverTimestamp(),
            'deadline': item['deadline'] is DateTime
                ? Timestamp.fromDate(item['deadline'])
                : Timestamp.now(),
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error adding finance: $e');
      rethrow;
    }
  }

  /// Get all finance items as a stream (UNIFIED - removed duplicate)
  Stream<List<Map<String, dynamic>>> getFinanceStream() {
    return _db
        .collection('users')
        .doc(userId)
        .collection('finance')
        .orderBy('deadline')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) {
              final data = d.data();
              return {
                'id': d.id,
                'title': data['title'] ?? '',
                'description': data['description'] ?? '',
                'name': data['name'] ?? '',
                'amount': (data['amount'] ?? 0.0).toDouble(),
                'isPaid': data['isPaid'] ?? false,
                'createDate': (data['createDate'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
                'deadline': (data['deadline'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
                'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
                'type': data['type'] ?? 'Expense',
              };
            })
            .toList());
  }

  Future<void> updateFinance(String financeId, Map<String, dynamic> data) async {
    try {
      final updateData = {...data};
      if (data['deadline'] is DateTime) {
        updateData['deadline'] = Timestamp.fromDate(data['deadline']);
      }
      if (data['createDate'] is DateTime) {
        updateData['createDate'] = Timestamp.fromDate(data['createDate']);
      }
      if (data['date'] is DateTime) {
        updateData['date'] = Timestamp.fromDate(data['date']);
      }
      await _db
          .collection('users')
          .doc(userId)
          .collection('finance')
          .doc(financeId)
          .update(updateData);
    } catch (e) {
      print('Error updating finance: $e');
      rethrow;
    }
  }

  Future<void> deleteFinance(String financeId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('finance')
          .doc(financeId)
          .delete();
    } catch (e) {
      print('Error deleting finance: $e');
      rethrow;
    }
  }

  // BALANCE
  Future<double> getCurrentBalance() async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      return (doc.data()?['balance'] ?? 0.0).toDouble();
    } catch (e) {
      print('Error getting balance: $e');
      return 0.0;
    }
  }

  Stream<double> getBalanceStream() {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snap) => (snap.data()?['balance'] ?? 0.0).toDouble());
  }

  Future<void> updateBalance(double newBalance) async {
    try {
      await _db.collection('users').doc(userId).set(
          {'balance': newBalance},
          SetOptions(merge: true),
        );
    } catch (e) {
      print('Error updating balance: $e');
      rethrow;
    }
  }

  Future<void> addToBalance(double amount) async {
    try {
      await _db.collection('users').doc(userId).update({
        'balance': FieldValue.increment(amount),
      });
    } catch (e) {
      print('Error incrementing balance: $e');
      rethrow;
    }
  }

  // EVENTS
  Future<void> addEvent(Event event) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('events')
          .add({
            'title': event.title,
            'description': event.description,
            'date': Timestamp.fromDate(event.date),
            'timeHour': event.time.hour,
            'timeMinute': event.time.minute,
            'type': event.type,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error adding event: $e');
      rethrow;
    }
  }

  Stream<Map<DateTime, List<Event>>> getEventsStream() {
    return _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .orderBy('date')
        .snapshots()
        .map((snap) {
      Map<DateTime, List<Event>> events = {};
      for (var doc in snap.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final dateKey = DateTime(date.year, date.month, date.day);
        final time = TimeOfDay(
          hour: data['timeHour'] ?? 0,
          minute: data['timeMinute'] ?? 0,
        );

        final event = Event(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: date,
          time: time,
          type: data['type'] ?? 'General',
        );

        if (events[dateKey] == null) {
          events[dateKey] = [];
        }
        events[dateKey]!.add(event);
      }
      return events;
    });
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  /// Get upcoming expenses (finance items with future dates)
  Stream<double> getUpcomingExpensesStream() {
    return _db
        .collection('users')
        .doc(userId)
        .collection('finance')
        .where('deadline', isGreaterThanOrEqualTo: DateTime.now())
        .snapshots()
        .map((snap) {
      double total = 0.0;
      for (var doc in snap.docs) {
        final amount = (doc['amount'] as num?)?.toDouble() ?? 0.0;
        total += amount;
      }
      return total;
    });
  }

  /// Get recent savings (finance items from last 30 days with positive amounts)
  Stream<double> getRecentSavingsStream() {
    return _db
        .collection('users')
        .doc(userId)
        .collection('finance')
        .where('deadline',
            isGreaterThanOrEqualTo:
                DateTime.now().subtract(const Duration(days: 30)))
        .snapshots()
        .map((snap) {
      double total = 0.0;
      for (var doc in snap.docs) {
        final amount = (doc['amount'] as num?)?.toDouble() ?? 0.0;
        if (amount > 0) total += amount;
      }
      return total;
    });
  }

  /// Get active (incomplete) tasks
  Stream<List<Map<String, dynamic>>> getActiveTasks() {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('completed', isEqualTo: false)
        .limit(3)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList());
  }

  /// Get completed tasks
  Stream<List<Map<String, dynamic>>> getCompletedTasks() {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('completed', isEqualTo: true)
        .limit(3)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList());
  }

  /// Get upcoming events
  Stream<List<Map<String, dynamic>>> getUpcomingEvents() {
    return _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: DateTime.now())
        .limit(4)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList());
  }

  /// Add a new finance item (expense/income)
  Future<void> addFinanceItem({
    required String name,
    required double amount,
    required String description,
    required DateTime date,
    String type = 'Expense',
  }) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('finance')
          .add({
            'name': name,
            'amount': amount,
            'description': description,
            'date': Timestamp.fromDate(date),
            'type': type,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error adding finance item: $e');
      rethrow;
    }
  }

  /// Delete a finance item
  Future<void> deleteFinanceItem(String itemId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('finance')
          .doc(itemId)
          .delete();
    } catch (e) {
      print('Error deleting finance item: $e');
      rethrow;
    }
  }

  /// Update a finance item
  Future<void> updateFinanceItem(
    String itemId, {
    String? name,
    double? amount,
    String? description,
    DateTime? date,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (amount != null) updateData['amount'] = amount;
      if (description != null) updateData['description'] = description;
      if (date != null) updateData['date'] = Timestamp.fromDate(date);

      await _db
          .collection('users')
          .doc(userId)
          .collection('finance')
          .doc(itemId)
          .update(updateData);
    } catch (e) {
      print('Error updating finance item: $e');
      rethrow;
    }
  }

  /// Search tasks by name or description
  // ...existing code...

  /// Search tasks by name or description
  Future<List<Map<String, dynamic>>> searchTasks(String query) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .get();
      
      return snap.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .where((task) {
            final name = (task['name'] as String?) ?? '';
            final description = (task['description'] as String?) ?? '';
            return name.toLowerCase().contains(query.toLowerCase()) ||
                   description.toLowerCase().contains(query.toLowerCase());
          })
          .toList();
    } catch (e) {
      print('Error searching tasks: $e');
      return [];
    }
  }

  /// Search finance items by name
  Future<List<Map<String, dynamic>>> searchFinance(String query) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(userId)
          .collection('finance')
          .get();
      
      return snap.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .where((item) {
            final name = (item['name'] as String?) ?? '';
            final title = (item['title'] as String?) ?? '';
            return name.toLowerCase().contains(query.toLowerCase()) ||
                   title.toLowerCase().contains(query.toLowerCase());
          })
          .toList();
    } catch (e) {
      print('Error searching finance: $e');
      return [];
    }
  }

  /// Search events by title
  Future<List<Map<String, dynamic>>> searchEvents(String query) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();
      
      return snap.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .where((event) {
            final title = (event['title'] as String?) ?? '';
            return title.toLowerCase().contains(query.toLowerCase());
          })
          .toList();
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }
  Future<String?> getUserProfilePicture() async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    return doc.data()?['profilePicture'] as String?;
  } catch (e) {
    print('Error fetching profile picture: $e');
    return null;
  }
}
  
}
