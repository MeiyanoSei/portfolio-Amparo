import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event_file.dart'; // Import the Event model

class ExpandedCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<Event>> events;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final Function(DateTime) onDayLongPressed;
  final Function(DateTime) getMarkerColor;
  final Function(DateTime) onAddEvent;

  const ExpandedCalendar({
    Key? key,
    required this.focusedDay,
    this.selectedDay,
    required this.events,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onDayLongPressed,
    required this.getMarkerColor,
    required this.onAddEvent,
  }) : super(key: key);

  @override
  State<ExpandedCalendar> createState() => _ExpandedCalendarState();
}

class _ExpandedCalendarState extends State<ExpandedCalendar> {
  List<Event> _getEventsForDay(DateTime day) {
    return widget.events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: widget.focusedDay,
      firstDay: DateTime.utc(1950, 1, 1),
      lastDay: DateTime.utc(2050, 12, 31),
      selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
      eventLoader: _getEventsForDay,
      onDaySelected: widget.onDaySelected,
      onPageChanged: widget.onPageChanged,
      onDayLongPressed: (selected, focused) {
        widget.onDayLongPressed(selected);
      },
      rowHeight: 40,
      headerVisible: false,
      daysOfWeekHeight: 40,
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty) {
            return Positioned.fill(
              child: Container(
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.getMarkerColor(date),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }
          return null;
        },
      ),
      calendarStyle: CalendarStyle(
        cellMargin: EdgeInsets.all(4),
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          color: Colors.grey,
           borderRadius: BorderRadius.circular(8),
        ),
        selectedDecoration: BoxDecoration(
          color: const Color.fromARGB(255, 151, 148, 106),
          borderRadius: BorderRadius.circular(8),
        ),
        markersMaxCount: 0,
        weekendTextStyle: TextStyle(color: Colors.red[200]),
        outsideTextStyle: TextStyle(color: Colors.grey[300]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        ),
        weekendStyle: TextStyle(
          color: Colors.red[200],
          fontSize: 13,
        ),
      ),
    );
  }
}