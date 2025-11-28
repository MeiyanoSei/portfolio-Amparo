import 'package:flutter/material.dart';
import 'package:listtest/todo_item.dart';
import 'package:listtest/task_Creation.dart';
import 'firebase_service.dart';

class ExpandedTasks extends StatefulWidget {
  final String userId;
  final List<Map<String, dynamic>> activeTasks;
  final List<Map<String, dynamic>> completedTasks;
  final VoidCallback onClose;

  const ExpandedTasks({
    super.key,
    required this.userId,
    required this.activeTasks,
    required this.completedTasks,
    required this.onClose,
  });

  @override
  State<ExpandedTasks> createState() => _ExpandedTasksState();
}

class _ExpandedTasksState extends State<ExpandedTasks> {
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
                color: Colors.white,
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
                        const Text('Active Tasks'),
                        const SizedBox(width: 140),
                        IconButton(
                          onPressed: () {
                            print('button pressed');
                          },
                          icon: const Icon(
                            Icons.menu,
                            size: 20,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        border: Border(
                          top: BorderSide(color: Colors.black, width: 0.2),
                          bottom: BorderSide(color: Colors.black, width: 0.2),
                        ),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          itemCount: widget.activeTasks.length,
                          itemBuilder: (context, index) {
                            final task = widget.activeTasks[index];
                            return ToDoItem(
                              id: task ['id'] ?? 'Null ID',
                              taskName: task['name'] ?? 'Unnamed Task',
                              taskCompleted: task['completed'] ?? false,
                              urgencyLevel: task['urgency'] ?? 'Normal',
                              deadline: task['deadline'] ?? DateTime.now(),
                              onChanged: (value) async {
                                if (value != null) {
                                  await _firebaseService.updateTask(
                                    task['id'],
                                    {'completed': value},
                                  );
                                }
                              },
                              onTaskMoved: () async {
                                await _firebaseService.updateTask(
                                  task['id'],
                                  {'completed': !task['completed']},
                                );
                              },
                              onDelete: () async {
                                try {
                                  await _firebaseService.deleteTask(task['id']);
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error deleting task: $e')),
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
                          builder: (context) => TaskCreationDialog(
                            onTaskCreated: (taskName, urgency, deadline) async {
                              try {
                                await _firebaseService.addTask({
                                  'name': taskName,
                                  'completed': false,
                                  'urgency': urgency,
                                  'deadline': deadline,
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Task created successfully!')),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error creating task: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                      shape: const CircleBorder(),
                      backgroundColor: const Color.fromARGB(255, 221, 221, 221),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}