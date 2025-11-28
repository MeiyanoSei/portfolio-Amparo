import 'package:flutter/material.dart';
import 'package:listtest/expanded_Expenditures.dart';
import 'finance_Item.dart';
import 'expanded_Finance.dart';
import 'firebase_service.dart';

class FinancePage extends StatefulWidget {
  final String userId;
  
  const FinancePage({super.key, required this.userId});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  bool isPressed = false;
  late FirebaseService _firebaseService;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService(userId: widget.userId);
  }

  void onClose() {
    Navigator.of(context).pop();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                StreamBuilder<double>(
                  stream: _firebaseService.getBalanceStream(),
                  builder: (context, snapshot) {
                    final currentBalance = snapshot.data ?? 0.0;
                    return Container(
                      width: 300,
                      height: 120,
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Current Balance",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                         Align(   
                          alignment: Alignment.center,                       
                           child: Text(
                            "₱${currentBalance.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                             ),
                            ),
        
                          ),
                        ],
                      ),
                    );
                  },
                ),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _firebaseService.getFinanceStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final allFinance = snapshot.data ?? [];
                    final unPaidList = allFinance.where((f) => f['isPaid'] == false).toList();
                    final paidList = allFinance.where((f) => f['isPaid'] == true).toList();

                    return Column(
                      children: [
                        _buildTaskSection('Unpaid Payments', unPaidList, true),
                        _buildTaskSection('Paid Payments', paidList, false),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskSection(String title, List<Map<String, dynamic>> items, bool isUnpaid) {
    return Container(
      width: 300,
      height: 400,
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Container(
            width: 300,
            height: 50,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 231, 231, 231),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 30),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 20,
                    fontWeight: FontWeight.w200
                    
                                        ,
                  ),
                ),
                const Spacer(flex: 4),
                IconButton(
                  icon: Icon(
                    fontWeight: FontWeight.w300,
                    Icons.add_rounded,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  onPressed: () {
                    setState(() {
                  
                    });
                    if (isUnpaid) {
                      showDialog(
                        context: context,
                        builder: (context) => ExpandedFinance(
                          userId: widget.userId,
                          unPaid: items,
                          financePaid: [],
                          onAddExpenditure: (amount) {},
                          onClose: onClose,
                        ),
                      );
                    } else {
                                          showDialog(
                        context: context,
                        builder: (context) => ExpandedExpenditures(
                          userId: widget.userId, 
                          paidExpenditures: items,
                          onClose: onClose)
                      );
                    }
                  },
                ),
                const SizedBox(width: 30),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(child: Text('No finance records', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w300),))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return FinanceItem(
                        title: item['title'] ?? 'Finance',
                        deadline: item['deadline'] ?? DateTime.now(),
                        description: item['description'] ?? '',
                        amount: item['amount'] ?? 0.0,
                        createDate: item['createDate'] ?? DateTime.now(),
                        isPaid: item['isPaid'] ?? false,
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
                          } else {
                            await _firebaseService.addToBalance(item['amount']);
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
        ],
      ),
    );
  }
}