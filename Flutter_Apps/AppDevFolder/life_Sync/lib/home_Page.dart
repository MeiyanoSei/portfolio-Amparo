import 'package:flutter/material.dart';
import 'firebase_service.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({
    super.key,
    required this.userId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FirebaseService _firebaseService;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
       
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Current Balance Card
              Container(
                margin: EdgeInsets.only(top: 20),
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<double>(
                        stream: _firebaseService.getBalanceStream(),
                        builder: (context, snapshot) {
                          final balance = snapshot.data ?? 0.0;
                          return Text(
                            '₱${balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Paid Expenses',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 5),
                              StreamBuilder<List<Map<String, dynamic>>>(
                                stream: _firebaseService.getFinanceStream(),
                                builder: (context, snapshot) {
                                  final finance = snapshot.data ?? [];
                                  // Filter only paid payments
                                  final paidPayments = finance.where((f) => f['isPaid'] == true).toList();
                                  // Sum their amounts
                                  final amount = paidPayments.fold<double>(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));
                                  return Text(
                                    '-₱${amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w200,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Unpaid Expense',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 5),
                              StreamBuilder<double>(
                                stream: _firebaseService.getUpcomingExpensesStream(),
                                builder: (context, snapshot) {
                                  final amount = snapshot.data ?? 0.0;
                                  return Text(
                                    '+₱${amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w200,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // To Do & Done Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // To Do Column
                  Container(
                    width: 140,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'To Do',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: StreamBuilder<List<Map<String, dynamic>>>(
                              stream: _firebaseService.getActiveTasks(),
                              builder: (context, snapshot) {
                                final tasks = snapshot.data ?? [];
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: tasks.length > 3 ? 3 : tasks.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        tasks[index]['name'] ?? 'Task',
                                        style: const TextStyle(fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                  ),
                  const SizedBox(width: 20),

                  // Done Column
                  Container(
                    width: 140,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: StreamBuilder<List<Map<String, dynamic>>>(
                              stream: _firebaseService.getCompletedTasks(),
                              builder: (context, snapshot) {
                                final tasks = snapshot.data ?? [];
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: tasks.length > 3 ? 3 : tasks.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        tasks[index]['name'] ?? 'Task',
                                        style: const TextStyle(fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Upcoming Events Section
              Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upcoming Events',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _firebaseService.getUpcomingEvents(),
                          builder: (context, snapshot) {
                            final events = snapshot.data ?? [];
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: events.length > 4 ? 4 : events.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          events[index]['title'] ?? 'Event',
                                          style: const TextStyle(fontSize: 11),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        events[index]['type'] ?? '',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
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
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
     ),
    );
  }
}