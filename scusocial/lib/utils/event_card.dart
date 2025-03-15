import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/calendar_service.dart';

class EventCard extends StatelessWidget {
  final String eventId;
  final Map<String, dynamic> eventData;
  final User user;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;

  EventCard({
    required this.eventId,
    required this.eventData,
    required this.user,
    required this.onDelete,
    required this.onViewDetails,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final eventName = eventData['name'] ?? 'No Title';
    final eventDate =
        (eventData['date'] as Timestamp?)?.toDate() ?? DateTime.now();
    final eventTime = eventData['time'] ?? 'Unknown Time';
    final eventLocation = eventData['location'] ?? 'No Location';
    final acceptedUsers = List<String>.from(eventData['accepted'] ?? []);

    final bool isAccepted = acceptedUsers.contains(user.uid);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.onSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '📅 ${eventDate.toLocal().toString().split(' ')[0].replaceAllMapped(RegExp(r'(\d{4})-(\d{2})-(\d{2})'), (match) {
                final year = match.group(1);
                final month = int.parse(match.group(2)!);
                final day = int.parse(match.group(3)!);
                const months = [
                  'January',
                  'February',
                  'March',
                  'April',
                  'May',
                  'June',
                  'July',
                  'August',
                  'September',
                  'October',
                  'November',
                  'December'
                ];
                return '${months[month - 1]} $day, $year';
              })} | ⏰ $eventTime',
              style: TextStyle(color: colors.onSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '📍 $eventLocation',
              style: TextStyle(color: colors.onSecondary.withOpacity(0.8)),
            ),
            const SizedBox(height: 10),
            Text(
              eventData['description'] ?? 'No Description',
              style: TextStyle(color: colors.onSecondary.withOpacity(0.9)),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '👥 ${acceptedUsers.length} Accepted',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: colors.onPrimary),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.comment, color: colors.primary),
                      onPressed: onViewDetails,
                    ),
                    if (user.uid == eventData['creatorId'])
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Accept/Decline Button
            Center(
              child: ElevatedButton.icon(
                icon: Icon(
                  isAccepted ? Icons.close : Icons.check,
                  color: colors.onSecondary,
                ),
                label: Text(isAccepted ? "Decline" : "Accept"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAccepted ? Colors.red : colors.primary,
                  foregroundColor: colors.onSecondary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _respondToEvent(eventId, !isAccepted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _parseEventTime(DateTime eventDate, String eventTime) {
    final timeParts = eventTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1].split(' ')[0]);
    final isPM = eventTime.toLowerCase().contains('pm');

    return DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      isPM ? (hour % 12) + 12 : hour,
      minute,
    );
  }

  void _respondToEvent(String eventId, bool accept) async {
    final eventDoc =
        FirebaseFirestore.instance.collection('events').doc(eventId);
    final userId = user.uid;

    if (accept) {
      await eventDoc.update({
        'accepted': FieldValue.arrayUnion([userId]),
      });

      final eventSnapshot = await eventDoc.get();
      final eventData = eventSnapshot.data();
      if (eventData == null) return;

      final eventName = eventData['name'];
      final eventDescription = eventData['description'];
      final eventLocation = eventData['location'];
      final eventDate = (eventData['date'] as Timestamp).toDate();
      final eventTime = eventData['time'];

      final eventStartTime = _parseEventTime(eventDate, eventTime);
      final eventEndTime = eventStartTime.add(Duration(hours: 1));

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final calendarId = userDoc.data()?['calendarId'];
      if (calendarId == null) return;

      final calendarService = CalendarService();
      final gcalEventId = await calendarService.addEventToPrivateCalendar(
        calendarId,
        eventName,
        eventStartTime,
        eventEndTime,
      );

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'gcalEventMappings.$eventId': gcalEventId,
      });
    } else {
      await eventDoc.update({
        'accepted': FieldValue.arrayRemove([userId]),
      });

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final calendarId = userDoc.data()?['calendarId'];
      final gcalEventId = userDoc.data()?['gcalEventMappings']?[eventId];

      if (calendarId != null && gcalEventId != null) {
        final calendarService = CalendarService();
        await calendarService.removeEventFromPrivateCalendar(
            calendarId, gcalEventId);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'gcalEventMappings.$eventId': FieldValue.delete(),
        });
      }
    }
  }
}
