import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scusocial/pages/event_details_page.dart'; // Import EventDetailsPage
import 'package:scusocial/pages/profile_page.dart'; // Import ProfileScreen

class EventPage extends StatelessWidget {
  final User user;
  final Future<void> Function() signOut;

  EventPage({required this.user, required this.signOut});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.displayName ?? "User"}'),
        actions: [
          IconButton(
            icon: Icon(Icons.people), // Friends Icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: user.uid),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createEvent(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('events').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final eventId = event.id;
                    final eventData = event.data() as Map<String, dynamic>;
                    final eventName = eventData['name'];
                    final eventDate = (eventData['date'] as Timestamp).toDate();
                    final eventTime = eventData['time'];
                    final eventDescription = eventData['description'];
                    final eventLocation = eventData['location'];
                    final acceptedUsers =
                        List<String>.from(eventData['accepted'] ?? []);
                    final eventCreatorId = eventData['creatorId'];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventName,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text('Date: ${eventDate.toLocal()}'),
                            Text('Time: $eventTime'),
                            SizedBox(height: 8),
                            Text('Location: $eventLocation'),
                            SizedBox(height: 8),
                            Text('Description: $eventDescription'),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${acceptedUsers.length} accepted'),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          _respondToEvent(eventId, true),
                                      child: Text('Accept'),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _respondToEvent(eventId, false),
                                      child: Text('Decline'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                if (user.uid == eventCreatorId)
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () =>
                                        _deleteEvent(eventId, context),
                                    color: Colors.red,
                                  ),
                              ],
                            ),
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: () =>
                                  _goToEventDetailsPage(context, eventId),
                              child: Text(
                                'View Comments',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: signOut,
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _createEvent(BuildContext context) {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _locationController = TextEditingController();
    DateTime? _selectedDate;
    TimeOfDay? _selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  _selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                },
                child: Text('Select Date'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  _selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                },
                child: Text('Select Time'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty &&
                    _selectedDate != null &&
                    _selectedTime != null &&
                    _descriptionController.text.isNotEmpty &&
                    _locationController.text.isNotEmpty) {
                  final eventTime = _selectedTime!.format(context);

                  // Add the event to Firestore without a placeholder comment
                  await _firestore.collection('events').add({
                    'name': _nameController.text,
                    'date': _selectedDate,
                    'time': eventTime,
                    'description': _descriptionController.text,
                    'location': _locationController.text,
                    'accepted': [],
                    'creatorId': user.uid,
                  });

                  Navigator.pop(context);
                } else {
                  print("Please fill out all fields!");
                }
              },
              child: Text('Post'),
            ),
          ],
        );
      },
    );
  }

  void _respondToEvent(String eventId, bool accept) async {
    final eventDoc = _firestore.collection('events').doc(eventId);
    final userId = user.uid;

    if (accept) {
      await eventDoc.update({
        'accepted': FieldValue.arrayUnion([userId]),
      });
    } else {
      await eventDoc.update({
        'accepted': FieldValue.arrayRemove([userId]),
      });
    }
  }

  void _deleteEvent(String eventId, BuildContext context) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      await _firestore.collection('events').doc(eventId).delete();
    }
  }

  void _goToEventDetailsPage(BuildContext context, String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(eventId: eventId, user: user),
      ),
    );
  }
}
