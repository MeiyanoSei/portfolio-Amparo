import 'package:flutter/material.dart';

class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final Function(bool?) onChanged;
  final String urgencyLevel;
  final DateTime deadline;
  String stringLimit(String text, int limit) {
    if (text.length <= limit) {
      return text;
    } else {
      return text.substring(0, limit) + '...';
    }
  }

  const ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deadline,
    this.urgencyLevel = 'Normal',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        minVerticalPadding: 0,
        dense: true,
        visualDensity: const VisualDensity(vertical: -4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          stringLimit(taskName, 15),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            letterSpacing: -0.1,    
            wordSpacing: -0.1,
            fontSize: 16,
            decoration: taskCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Transform.translate(
          offset: const Offset(0, -3),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              margin: const EdgeInsets.only(right: 30,),
              decoration: BoxDecoration(
                color: _getUrgencyColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getUrgencyText(),
                style: const TextStyle(
                  letterSpacing: -0.1,
                  color: Colors.white,
                  fontSize: 8,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(85, -12),
             child: Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 0, left: 0),
              child: Text(
                _getFormattedDateTime(),
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.1,
                  wordSpacing: 3,
                  fontSize: 10,
                  color: Color.fromARGB(186, 117, 117, 117),
                ),
              ),
              ),
            )
          ],
        ),
      ),
        trailing: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: taskCompleted
              ? Container(
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 45, 255, 80),
                  ),
                )
              : null,
        ),
        onTap: () => onChanged(!taskCompleted),
      ),
    );
  }

  String _getUrgencyText() {
    switch (urgencyLevel.toLowerCase()) {
      case 'high': return 'H';
      case 'medium': return 'M';
      case 'low': return 'L';
      default: return 'N';
    }
  }

  Color _getUrgencyColor() {
    switch (urgencyLevel.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.blue;
    }
  }

  String _getFormattedDateTime() {
   return '${deadline.month}/${deadline.day}/${deadline.year.toString().substring(2)} ${_formatTime(deadline)}';
  }

  String _formatTime(DateTime dateTime) {
    var hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    
    hour = hour > 12 ? hour - 12 : hour;
    hour = hour == 0 ? 12 : hour;
    
    return '$hour:$minute$period';
  }
}