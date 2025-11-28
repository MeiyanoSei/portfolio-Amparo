import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'finance_Item.dart';
import 'finance_Creation.dart';

class ExpandedExpenditures extends StatefulWidget {
  final String userId;
  final VoidCallback onClose;
  final List<Map<String, dynamic>> paidExpenditures;

  const ExpandedExpenditures({
    super.key,
    required this.paidExpenditures,
    required this.userId,
    required this.onClose,
  });

  @override
  State<ExpandedExpenditures> createState() => _ExpandedExpendituresState();
}

class _ExpandedExpendituresState extends State<ExpandedExpenditures> {
  late FirebaseService _firebaseService;
  bool _isLoading = true;
  List<Map<String, dynamic>> _expenditures = [];

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService(userId: widget.userId);
    _listenExpenditures();
  }

  void _listenExpenditures() {
    _firebaseService.getFinanceStream().listen((financeItems) {
      setState(() {
        _expenditures =
            financeItems.where((f) => f['isPaid'] == true).toList(); // only expenditures
        _isLoading = false;
      });
    });
  }

  Future<void> _markPaid(Map<String, dynamic> item, bool value) async {
    await _firebaseService.updateFinance(item['id'], {'isPaid': value});
    if (!value) {
      await _firebaseService.addToBalance(item['amount']);
    } else {
      await _firebaseService.addToBalance(-item['amount']);
    }
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
                      color: Colors.black26, blurRadius: 10, spreadRadius: 3),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Expenditures',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _expenditures.isEmpty
                            ? const Center(
                                child: Text('No paid expenditures yet'))
                            : ListView.builder(
                                itemCount: _expenditures.length,
                                itemBuilder: (context, index) {
                                  final item = _expenditures[index];
                                  return FinanceItem(
                                    isPaid: item['isPaid'],
                                    title: item['title'],
                                    description: item['description'] ?? '',
                                    amount: item['amount'],
                                    createDate: item['createDate'] ??
                                        DateTime.now(),
                                    deadline:
                                        item['deadline'] ?? DateTime.now(),
                                    paidFinance: (value) {
                                      if (value != null) {
                                        _markPaid(item, value);
                                      }
                                    },
                                    onFinanceMoved: () {
                                      final newStatus = !item['isPaid'];
                                      _markPaid(item, newStatus);
                                    },
                                    onDelete: () async {
                                      try {
                                        await _firebaseService
                                            .deleteFinance(item['id']);
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Error deleting: $e')));
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => FinanceCreationDialog(
                          onCreate: (title, description, amount, deadline,
                              createDate) async {
                            try {
                              await _firebaseService.addFinance({
                                'title': title,
                                'description': description,
                                'amount': amount,
                                'createDate': createDate,
                                'deadline': deadline,
                                'isPaid': true, // new expenditure marked as paid
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Expenditure created!')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Error creating expenditure: $e')),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                    shape: const CircleBorder(),
                    backgroundColor: Colors.white,
                    child:
                        const Icon(Icons.add, size: 30, color: Colors.red),
                  ),
                        const SizedBox(height: 30,)
        
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
