import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TaskCreationDialog extends StatefulWidget {
  final Function(String taskName, String urgency, DateTime deadline) onTaskCreated;

  const TaskCreationDialog({
    super.key,
    required this.onTaskCreated,
  });

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  String taskName = '';
  String selectedUrgency = 'Low';
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
    _dateController = TextEditingController(
      text: ""
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task Creation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 226, 226, 226),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Enter Task',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) => taskName = value,
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  _buildUrgencyOption('Light Urgency', 'Low'),
                  _buildUrgencyOption('Medium Urgency', 'Medium'),
                  _buildUrgencyOption('High Urgency', 'High'),
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                'Enter Deadline',
                style: TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 243, 243, 243),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _dateController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'DD/MM/YY',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  readOnly: true,
                  onTap: () => _showDatePicker(context),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 80,
                    child: _buildTimePicker(),
                  ),
                  const Text(
                    '|',
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 20,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    height: 80,
                    child: _buildMinutePicker(),
                  ),
                  const Text(
                    '|',
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 20,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 80,
                    child: _buildAMPMPicker(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        color: Colors.redAccent,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (taskName.isNotEmpty) {
                        final DateTime finalDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        widget.onTaskCreated(
                          taskName,
                          selectedUrgency,
                          finalDateTime,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.w200,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return CupertinoPicker.builder(
      backgroundColor: Colors.transparent,
      selectionOverlay: null,
      itemExtent: 40,
      childCount: 12,
      diameterRatio: 100,
      squeeze: 0.8,
      useMagnifier: true,
      magnification: 1.1,
      scrollController: FixedExtentScrollController(
        initialItem: selectedTime.hour > 12 
            ? selectedTime.hour - 12 
            : selectedTime.hour == 0 ? 11 : selectedTime.hour - 1,
      ),
      onSelectedItemChanged: (int index) {
        final newHour = index + 1;
        setState(() {
          selectedTime = TimeOfDay(
            hour: selectedTime.period == DayPeriod.pm 
                ? newHour + 12 
                : newHour,
            minute: selectedTime.minute,
          );
        });
      },
      itemBuilder: (context, index) {
        return Center(
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinutePicker() {
    return CupertinoPicker.builder(
      backgroundColor: Colors.transparent,
      selectionOverlay: null,
      itemExtent: 40,
      childCount: 60,
      diameterRatio: 100,
      squeeze: 0.8,
      useMagnifier: true,
      magnification: 1.1,
      scrollController: FixedExtentScrollController(
        initialItem: selectedTime.minute,
      ),
      onSelectedItemChanged: (int index) {
        setState(() {
          selectedTime = TimeOfDay(
            hour: selectedTime.hour,
            minute: index,
          );
        });
      },
      itemBuilder: (context, index) {
        return Center(
          child: Text(
            index.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAMPMPicker() {
    return CupertinoPicker.builder(
      backgroundColor: Colors.transparent,
      selectionOverlay: null,
      itemExtent: 40,
      childCount: 2,
      diameterRatio: 100,
      squeeze: 0.8,
      useMagnifier: true,
      magnification: 1.1,
      scrollController: FixedExtentScrollController(
        initialItem: selectedTime.period == DayPeriod.pm ? 1 : 0,
      ),
      onSelectedItemChanged: (int index) {
        setState(() {
          final newHour = selectedTime.hourOfPeriod +
              (index == 1 ? 12 : 0);
          selectedTime = TimeOfDay(
            hour: newHour,
            minute: selectedTime.minute,
          );
        });
      },
      itemBuilder: (context, index) {
        return Center(
          child: Text(
            index == 0 ? 'AM' : 'PM',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUrgencyOption(String label, String value) {
    final bool isSelected = selectedUrgency == value;
    Color buttonColor;
    switch (value.toLowerCase()) {
      case 'high':
        buttonColor = const Color.fromARGB(255, 255, 17, 0);
        break;
      case 'medium':
        buttonColor = Colors.orange;
        break;
      case 'low':
        buttonColor = const Color.fromARGB(255, 10, 219, 27);
        break;
      default:
        buttonColor = const Color.fromARGB(255, 0, 247, 255);
    }

    return GestureDetector(
      onTap: () => setState(() => selectedUrgency = value),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? buttonColor : const Color.fromARGB(255, 240, 240, 240),
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? buttonColor : Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year.toString().substring(2)}";
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }
}