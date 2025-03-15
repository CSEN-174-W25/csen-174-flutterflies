import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final String userId;
  final dynamic
      firestoreService; // Replace with FirestoreService type when available

  // Constructor to initialize the EventCard with event data, userId, and FirestoreService
  EventCard({
    required this.event,
    required this.userId,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['name'] ?? 'Untitled Event', // Default value for name
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis, // Prevent overflow
              maxLines: 1,
            ),
            SizedBox(height: 8),
            Text('Date: ${event['date'] ?? 'TBD'}'), // Default date
            Text('Time: ${event['time'] ?? 'TBD'}'), // Default time
            SizedBox(height: 8),
            Text(
                'Location: ${event['location'] ?? 'No location specified'}'), // Default location
            SizedBox(height: 8),
            Text(
              event['description'] ??
                  'No description provided.', // Default description
              maxLines: 3, // Limit lines for description
              overflow: TextOverflow.ellipsis, // Show ellipsis if too long
            ),
          ],
        ),
      ),
    );
  }
}
