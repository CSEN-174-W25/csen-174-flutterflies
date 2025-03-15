import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;
  final User user;

  EventDetailsPage({required this.eventId, required this.user});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  // Initialize FirestoreService with FirebaseFirestore instance
  final FirestoreService _firestoreService =
      FirestoreService(firestore: FirebaseFirestore.instance);
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .doc(widget.eventId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final event = snapshot.data!;
                final eventData = event.data() as Map<String, dynamic>;
                final eventName = eventData['name'];
                final eventDate = (eventData['date'] as Timestamp).toDate();
                final eventTime = eventData['time'];
                final eventDescription = eventData['description'];
                final eventLocation = eventData['location'];

                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    Text(
                      eventName,
                      style:
                          const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text('Date: ${eventDate.toLocal()}'),
                    Text('Time: $eventTime'),
                    Text('Location: $eventLocation'),
                    Text('Description: $eventDescription'),
                    const SizedBox(height: 16),
                    const Text('Comments:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.getComments(widget.eventId),
                      builder: (context, commentSnapshot) {
                        if (!commentSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final comments = commentSnapshot.data!.docs;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment =
                                comments[index].data() as Map<String, dynamic>;
                            final userName = comment['userName'] ?? 'Anonymous';
                            final message = comment['message'] ?? '[No message]';
                            final timestamp = comment['timestamp'] as Timestamp?;
                            final formattedTime = timestamp != null
                                ? DateFormat.yMMMd()
                                    .add_jm()
                                    .format(timestamp.toDate())
                                : 'Unknown time';

                            return ListTile(
                              title: Text('$userName • $formattedTime'),
                              subtitle: Text(message),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                  labelText: 'Write a comment...'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () async {
                              final commentText = _commentController.text.trim();
                              if (commentText.isNotEmpty) {
                                await _firestoreService.addComment(
                                  eventId: widget.eventId,
                                  userName: widget.user.displayName ?? 'Anonymous',
                                  message: commentText,
                                );
                                _commentController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
