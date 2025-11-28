import 'package:flutter/material.dart';

class FinanceTile extends StatelessWidget {
final String title;
final DateTime deadline;
final bool isPaid;
final Function(bool?) paidFinance;
final String description;
final double amount;
final DateTime createDate;

const FinanceTile({
super.key,
required this.title,
required this.deadline,
required this.description,
required this.amount,
required this.createDate,
required this.isPaid,
required this.paidFinance,
});

@override
Widget build(BuildContext context) {
return Container(
padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
color: Colors.white, // White background
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// LEFT COLUMN (Title + Due Date)
Expanded(
flex: 3,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
decoration: isPaid ? TextDecoration.lineThrough : null,
),
),
const SizedBox(height: 4),
Text(
_formatDeadline(deadline),
style: TextStyle(
fontSize: 11,
fontStyle: FontStyle.italic,
color: Colors.grey[700],
),
),
],
),
),


      // MIDDLE COLUMN (Description)
      Expanded(
        flex: 3,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ),
      ),

      // RIGHT COLUMN (Amount + CreateDate)
      Expanded(
        flex: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              "PHP",
              style: TextStyle(
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
            Text(
              amount.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _formatCreateDate(createDate),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);


}

// DATE HELPERS
String _formatDeadline(DateTime date) {
final h = date.hour > 12 ? date.hour - 12 : date.hour;
final period = date.hour >= 12 ? "PM" : "AM";
final minutes = date.minute.toString().padLeft(2, '0');
return "${date.month}/${date.day}/${date.year}  $h:$minutes $period";
}

String _formatCreateDate(DateTime date) {
return "${date.month}/${date.day}/${date.year}";
}
}
