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
    final eventName = eventData['name'] ?? 'No Title';
    final eventDate =
        (eventData['date'] as Timestamp?)?.toDate() ?? DateTime.now();
    final eventTime = eventData['time'] ?? 'Unknown Time';
    final eventLocation = eventData['location'] ?? 'No Location';
    final acceptedUsers = List<String>.from(eventData['accepted'] ?? []);

    final bool isAccepted = acceptedUsers.contains(user.uid);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eventName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('📅 ${eventDate.toLocal()} | ⏰ $eventTime'),
            const SizedBox(height: 8),
            Text('📍 $eventLocation',
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('👥 ${acceptedUsers.length} Accepted',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.comment, color: Colors.blue),
                        onPressed: onViewDetails),
                    if (user.uid == eventData['creatorId'])
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: onDelete),
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
                  icon: const Icon(Icons.check),
                  label: Text(isAccepted ? "Accepted" : "Accept"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAccepted ? Colors.green : Colors.blue,
                  ),
                  onPressed:
                      isAccepted ? null : () => _respondToEvent(eventId, true),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text("Decline"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
