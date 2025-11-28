import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'expanded_calendar.dart';
import 'event_file.dart';
import 'firebase_service.dart';

class CalendarPage extends StatefulWidget {
  final String userId;

  const CalendarPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime today = DateTime.now();
  DateTime? selectedDay;
  String month = DateFormat('MMMM').format(DateTime.now());
  String dateString = DateFormat('MM/dd/yyyy').format(DateTime.now());
  String timeString = DateFormat('hh:mm a').format(DateTime.now());

  Map<DateTime, List<Event>> events = {};
  late FirebaseService _firebaseService;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedDay = today;
    _firebaseService = FirebaseService(userId: widget.userId);
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    _firebaseService.getEventsStream().listen((eventsData) {
      setState(() {
        events = eventsData;
        isLoading = false;
      });
    }, onError: (error) {
      print('Error loading events: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  List<Event> get upcomingEvents {
    List<Event> upcoming = [];
    events.forEach((date, eventList) {
      upcoming.addAll(eventList.where((event) => event.isUpcoming));
    });
    upcoming.sort((a, b) {
      final aDateTime = DateTime(a.date.year, a.date.month, a.date.day, a.time.hour, a.time.minute);
      final bDateTime = DateTime(b.date.year, b.date.month, b.date.day, b.time.hour, b.time.minute);
      return aDateTime.compareTo(bDateTime);
    });
    return upcoming;
  }

  List<Event> get otherEvents {
    List<Event> other = [];
    events.forEach((date, eventList) {
      other.addAll(eventList.where((event) => !event.isUpcoming));
    });
    other.sort((a, b) {
      final aDateTime = DateTime(a.date.year, a.date.month, a.date.day, a.time.hour, a.time.minute);
      final bDateTime = DateTime(b.date.year, b.date.month, b.date.day, b.time.hour, b.time.minute);
      return bDateTime.compareTo(aDateTime);
    });
    return other;
  }

  Future<void> _showAddEventDialog(DateTime selectedDate) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final typeController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Add Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: 'Event Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Time: ${selectedTime.format(context)}', style: TextStyle(color: Colors.white),),
                        const Icon(Icons.access_time, color: Colors.white,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                SizedBox(width: 20,),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w300),
                  ),
                ),
                const SizedBox(width: 85),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 161, 161, 161),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      
                    ),
                  ),
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      final newEvent = Event(
                        title: titleController.text,
                        description: descriptionController.text,
                        date: selectedDate,
                        time: selectedTime,
                        type: typeController.text.isEmpty ? 'General' : typeController.text,
                      );

                      try {
                        await _firebaseService.addEvent(newEvent);
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Event added successfully!')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error adding event: $e')),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(DateTime day) {
    final dayEvents = _getEventsForDay(day);
    if (dayEvents.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Events on ${DateFormat('MMM dd, yyyy').format(day)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: dayEvents.map((event) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Time: ${event.time.format(context)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Type: ${event.type}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getMarkerColor(DateTime eventDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
    
    final difference = checkDate.difference(today).inDays;
    
    if (difference < 0) {
      return Colors.grey.withOpacity(0.3);
    } else if (difference == 0) {
      return Colors.red.withOpacity(0.7);
    } else if (difference <= 7) {
      final ratio = difference / 7.0;
      return Color.lerp(
        Colors.red.withOpacity(0.7),
        Colors.cyan.withOpacity(0.7),
        ratio,
      )!;
    } else {
      return Colors.cyan.withOpacity(0.7);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final upcoming = upcomingEvents;
    final other = otherEvents;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 231, 231, 231),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              month,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      dateString,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      timeString,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    _showAddEventDialog(selectedDay ?? today);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ExpandedCalendar(
                          focusedDay: today,
                          selectedDay: selectedDay,
                          events: events,
                          onDaySelected: (selected, focused) {
                            setState(() {
                              selectedDay = selected;
                              today = focused;
                            });
                          },
                          onPageChanged: (newFocusedDay) {
                            setState(() {
                              today = newFocusedDay;
                              month = DateFormat('MMMM').format(newFocusedDay);
                            });
                          },
                          onDayLongPressed: _showEventDetails,
                          getMarkerColor: _getMarkerColor,
                          onAddEvent: _showAddEventDialog,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Upcoming Events',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      if (upcoming.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          child: Text(
                            'No upcoming events',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        )
                      else
                        ...upcoming.take(3).map((event) => _buildEventTile(event)),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Other Events',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      if (other.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          child: Text(
                            'No other events',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        )
                      else
                        ...other.map((event) => _buildEventTile(event)),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventTile(Event event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('MMM dd').format(event.date)} at ${event.time.format(context)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                event.type,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Event Type',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[300], size: 20),
            onPressed: () async {
              if (event.id != null) {
                try {
                  await _firebaseService.deleteEvent(event.id!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event deleted successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting event: $e')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}