import 'package:flutter/material.dart';
import 'package:listtest/finance_Tile.dart';

class FinanceItem extends StatefulWidget{
  final String title;
  final DateTime deadline;
  final Function (bool?) paidFinance;
  final bool isPaid; 
  final VoidCallback onFinanceMoved;
  final String  description;
  final double amount;
  final DateTime createDate;
  final VoidCallback onDelete;

  const FinanceItem({
  super.key,
  required this.paidFinance,
  required this.onFinanceMoved,
  required this.title,
  required this.deadline,
  required this.description,
  required this.amount,
  required this.createDate,
  required this.isPaid,
  required this.onDelete,
});

  @override
  State<FinanceItem> createState() => _FinanceItemState();
}
  class _FinanceItemState extends State <FinanceItem>{
    Color containerColor = const Color.fromARGB(255, 24, 104, 32);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top:BorderSide(width: 0.5, color: const Color.fromARGB(255, 238, 238, 238)),
          bottom: BorderSide(width: 0.5, color: const Color.fromARGB(255, 233, 233, 233)), 
          )
      ),
      child: ClipRRect(
        child: Dismissible(
          key: ValueKey(widget.title),
          direction: DismissDirection.horizontal,

          background: Container(
          color: const Color.fromARGB(255, 0, 255, 68),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 16),
          child: const Icon(Icons.check, color: Colors.white, size: 22),
          ),

          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white, size: 22),
          ),

          onUpdate: (details) {

            setState((){
              if (details.reached) return;
              containerColor = details.direction == DismissDirection.startToEnd
                ? const Color.fromARGB(255, 255, 242, 0)
                : Colors.red;
            });
          },

          onDismissed: (direction) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(direction == DismissDirection.startToEnd
                      ? '${widget.title} Paid'
                      : '${widget.title} Removed'),
                  duration: const Duration(seconds: 1),
                ),
              );
            });

            if (direction == DismissDirection.startToEnd) {
              widget.onFinanceMoved();
            } else if (direction == DismissDirection.endToStart) {
              widget.onDelete();
            }
          },

          child: Container ( 
            color: containerColor,
            child: FinanceTile(
              paidFinance: widget.paidFinance,
              title: widget.title,
              description: widget.description,
              amount: widget.amount,
              deadline: widget.deadline,
              createDate: widget.createDate,
              isPaid: widget.isPaid,
            ))
        ),
      ),
    );
  }
}