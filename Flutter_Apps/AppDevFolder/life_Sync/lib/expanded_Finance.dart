import 'package:flutter/material.dart';
import 'package:listtest/finance_Item.dart';
import 'package:listtest/finance_Creation.dart';
import 'firebase_service.dart';

class ExpandedFinance extends StatefulWidget {
  final String userId;
  final List<Map<String, dynamic>> unPaid;
  final List<Map<String, dynamic>> financePaid;
  final VoidCallback onClose;
  final Function(double amount) onAddExpenditure;

  const ExpandedFinance({
    super.key,
    required this.userId,
    required this.unPaid,
    required this.financePaid,
    required this.onClose,
    required this.onAddExpenditure,
  });

  @override
  State<ExpandedFinance> createState() => _ExpandedFinanceState();
}

class _ExpandedFinanceState extends State<ExpandedFinance> {
  late FirebaseService _firebaseService;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Material(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 300,
              height: 500,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 244, 244, 244),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 3,
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: const Offset(0, 3),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        const Text('Unpaid Payments'),
                        const SizedBox(width: 100),
                        IconButton(
                          onPressed: () {
                            print('button pressed');
                          },
                          icon: const Icon(
                            Icons.menu,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.black, width: 0.2),
                          bottom: BorderSide(color: Colors.black, width: 0.2),
                        ),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          itemCount: widget.unPaid.length,
                          itemBuilder: (context, index) {
                            final item = widget.unPaid[index];
                            return FinanceItem(
                              isPaid: item['isPaid'],
                              title: item['title'],
                              description: item['description'] ?? '',
                              amount: item['amount'],
                              createDate: item['createDate'] ?? DateTime.now(),
                              deadline: item['deadline'] ?? DateTime.now(),
                              paidFinance: (value) async {
                                if (value != null) {
                                  await _firebaseService.updateFinance(
                                    item['id'],
                                    {'isPaid': value},
                                  );
                                }
                              },
                              onFinanceMoved: () async {
                                final newPaidStatus = !item['isPaid'];
                                await _firebaseService.updateFinance(
                                  item['id'],
                                  {'isPaid': newPaidStatus},
                                );
                                
                                if (newPaidStatus) {
                                  await _firebaseService.addToBalance(-item['amount']);
                                  widget.onAddExpenditure(item['amount']);
                                }
                              },
                              onDelete: () async {
                                try {
                                  await _firebaseService.deleteFinance(item['id']);
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error deleting: $e')),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Transform.translate(
                    offset: const Offset(0, -7.5),
                    child: FloatingActionButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => FinanceCreationDialog(
                            onCreate: (title, description, amount, deadline, createDate) async {
                              try {
                                await _firebaseService.addFinance({
                                  'title': title,
                                  'description': description,
                                  'amount': amount,
                                  'createDate': createDate,
                                  'deadline': deadline,
                                  'isPaid': false,
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Finance item created successfully!')),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error creating finance item: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.add, size: 30, color: Colors.red),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}