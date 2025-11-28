import 'package:flutter/material.dart';
import 'package:listtest/todo_tile.dart';

class ToDoItem extends StatefulWidget {
  final String taskName;
  final bool taskCompleted;
  final Function(bool?) onChanged;
  final VoidCallback onTaskMoved;
  final String urgencyLevel;
  final DateTime deadline;
  final VoidCallback onDelete;
  final String id;

  const ToDoItem({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.onTaskMoved,
    required this.deadline,
    required this.onDelete,
    required this.id,
    this.urgencyLevel = 'Normal',
  });

  @override
  State<ToDoItem> createState() => _ToDoItemState();
}

class _ToDoItemState extends State<ToDoItem> {
  Color containerColor = const Color.fromARGB(255, 255, 255, 255);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 12, right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Dismissible(
          key: ValueKey(widget.id),
          direction: DismissDirection.horizontal,

          // swipe right background
          background: Container(
            color: Color.fromARGB(255, 2, 245, 54),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16),
            child: const Icon(Icons.restore, color: Colors.white, size: 22),
          ),

          // swipe left background
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white, size: 22),
          ),

          // ⚡ This changes color dynamically during drag
          onUpdate: (details) {
            setState(() {
              if (details.reached) return; // ignore if swipe completed
              containerColor =
                  details.direction == DismissDirection.startToEnd
                      ? const Color.fromARGB(255, 2, 245, 54)
                      : Colors.red;
            });
          },

          onDismissed: (direction) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(direction == DismissDirection.startToEnd
                      ? '${widget.taskName} Completed'
                      : '${widget.taskName} Deleted '),
                  duration: const Duration(seconds: 1),
                ),
              );
            });

            if (direction == DismissDirection.startToEnd) {
              widget.onTaskMoved();
            } else {
              widget.onDelete();
            }
          },

          child: Container(
            color: containerColor,
            child: ToDoTile(
            taskName: widget.taskName,
            taskCompleted: widget.taskCompleted,
            onChanged: widget.onChanged,
            urgencyLevel: widget.urgencyLevel,
            deadline: widget.deadline, 
            ),
          ),
        ),
      ),
    );
  }
}
