import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventCard extends StatelessWidget {
  final String eventId;
  final Map<String, dynamic> eventData;
  final User user;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;

  const EventCard({
    required this.eventId,
    required this.eventData,
    required this.user,
    required this.onDelete,
    required this.onViewDetails,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the theme
    final colors = theme.colorScheme; // Get color scheme

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
      color: colors.surface, // Use the correct theme color for card
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
                color: colors.onSecondary, // Use text color from theme
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '📅 ${eventDate.toLocal()} | ⏰ $eventTime',
              style: TextStyle(color: colors.onSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '📍 $eventLocation',
              style: TextStyle(color: colors.onSecondary.withOpacity(0.8)),
            ),
            const SizedBox(height: 10),
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
            // Accept/Decline Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.check, color: colors.onSecondary),
                  label: Text(isAccepted ? "Accepted" : "Accept"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isAccepted ? colors.secondary : colors.primary,
                    foregroundColor: colors.onSecondary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed:
                      isAccepted ? null : () => _respondToEvent(eventId, true),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.close, color: colors.onSecondary),
                  label: const Text("Decline"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.secondary,
                    foregroundColor: colors.onSecondary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => _respondToEvent(eventId, false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _respondToEvent(String eventId, bool accept) async {
    final eventDoc =
        FirebaseFirestore.instance.collection('events').doc(eventId);

    if (accept) {
      await eventDoc.update({
        'accepted': FieldValue.arrayUnion([user.uid]),
      });
    } else {
      await eventDoc.update({
        'accepted': FieldValue.arrayRemove([user.uid]),
      });
    }
  }
}
