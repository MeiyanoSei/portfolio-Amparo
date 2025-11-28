import 'package:flutter/material.dart';
import 'todo_item.dart';
import 'expanded_Widget.dart';
import 'firebase_service.dart';

class TodoPage extends StatefulWidget {
  final String userId;
  const TodoPage({super.key, required this.userId});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
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
      extendBody: true,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Center(
          child: SingleChildScrollView(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firebaseService.getTasksStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final allTasks = snapshot.data ?? [];
                final activeTasks = allTasks.where((t) => t['completed'] == false).toList();
                final completedTasks = allTasks.where((t) => t['completed'] == true).toList();

                return Column(
                  children: [
                    Container(
                      width: 300,
                      height: 150,
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.only(bottom: 10, top:10, left: 20, right:15),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Task Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '${activeTasks.length}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w300,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                  const Text('Active'),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${completedTasks.length}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w300,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                  const Text('Completed'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildTaskSection('Active Tasks', activeTasks, true),
                    _buildTaskSection('Done', completedTasks, false),
                    const SizedBox(height: 100),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskSection(String title, List<Map<String, dynamic>> tasks, bool isActive) {
    return Container(
      width: 300,
      height: 300,
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
            decoration: const BoxDecoration(
             color: Color.fromARGB(255, 231, 231, 231),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const Spacer(),
              if (isActive)
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  onPressed: () {
                    setState(() {

                    });
                    if (isActive) {
                      showDialog(
                        context: context,
                        builder: (context) => ExpandedTasks(
                          userId: widget.userId,
                          activeTasks: tasks,
                          completedTasks: [],
                          onClose: onClose,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          SizedBox(
            height: 240,
            width: 300,
            child: tasks.isEmpty
                ? Center(child: Text('No tasks', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w300)), )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ToDoItem(
                        id: task['id'],
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
        ],
      ),
    );
  }
}