import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String? id; // Firebase document ID
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String type;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.type,
  });

  bool get isUpcoming {
    final now = DateTime.now();
    final eventDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return eventDateTime.isAfter(now);
  }

  // Convert Event to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'timeHour': time.hour,
      'timeMinute': time.minute,
      'type': type,
    };
  }

  // Create Event from Firebase document
  factory Event.fromMap(Map<String, dynamic> map, String id) {
    final timestamp = map['date'] as Timestamp;
    return Event(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: timestamp.toDate(),
      time: TimeOfDay(
        hour: map['timeHour'] ?? 0,
        minute: map['timeMinute'] ?? 0,
      ),
      type: map['type'] ?? 'General',
    );
  }
}