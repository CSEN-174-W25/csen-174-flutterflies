import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scusocial/pages/profile_screen.dart';

// import calendar servcie
import '../services/calendar_service.dart';
import '../features/friends/search_user_screen.dart';
import '../services/firestore_service.dart';
import '../pages/manage_friends.dart';

import 'group/group_page.dart';

import 'group/create_group.dart';
import 'group/search_group.dart';

import '../utils/event_card.dart';


class EventPage extends StatelessWidget {
  final User user;
  final Future<void> Function() signOut;
  final bool eventIsTesting;
  final FirestoreService _firestoreService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EventPage({
    required this.user,
    required this.signOut,
    required this.eventIsTesting,
    Key? key,
  })  : _firestoreService =
            FirestoreService(firestore: FirebaseFirestore.instance),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Call method to clean up past events on build
    _cleanupPastEvents();

    return Scaffold(

      appBar: _buildAppBar(context),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildEventList(),
    );
  }

  void _cleanupPastEvents() async {
    final now = DateTime.now();

    try {
      // Get all events created by the current user
      final querySnapshot = await _firestore
          .collection('events')
          .where('creatorId', isEqualTo: user.uid)
          .get();

      for (var doc in querySnapshot.docs) {
        final eventData = doc.data();
        final eventDate = (eventData['date'] as Timestamp).toDate();
        final eventTime = eventData['time'] as String;

        // Combine date and time to get full event datetime
        final fullEventDateTime = _parseEventTime(eventDate, eventTime);

        // If the event is in the past, delete it
        if (fullEventDateTime.isBefore(now)) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print('Error cleaning up past events: $e');
    }
  }


  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Welcome, ${user.displayName ?? 'User'}'),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 4.0,
      leading: IconButton(
        icon: Icon(Icons.calendar_today, color: Theme.of(context).cardColor),
        onPressed: () => _showCalendarSubscriptionLink(context),
      ),
      actions: [
        IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).cardColor),
            onPressed: () =>
                _createEvent(context, user.uid, _firestoreService)),
        IconButton(
          icon: Icon(Icons.group_add, color: Theme.of(context).cardColor),
          onPressed: () => _navigateTo(context, CreateGroupPage()),
        ),
        IconButton(
          icon: Icon(Icons.person, color: Theme.of(context).cardColor),
          onPressed: () =>
              _navigateTo(context, ProfileScreen(userId: user.uid)),
        ),
        IconButton(
          icon: Icon(Icons.group_add, color: Theme.of(context).cardColor),
          onPressed: () =>
              _navigateTo(context, GroupPage()),
        ),
        IconButton(
          icon: Icon(Icons.groups, color: Theme.of(context).cardColor),
          onPressed: () => _navigateTo(context, SearchGroupPage()),
        ),
        IconButton(
            icon: Icon(Icons.group, color: Theme.of(context).cardColor),
            onPressed: () => _navigateTo(context, ManageFriends())),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Theme.of(context).cardColor),
          onSelected: (value) {
            if (value == 'sign_out') signOut();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'sign_out', child: Text('Sign Out')),
          ],
        ),
      ],
    );
  }

  Widget _buildEventList() {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        final List<String> friendsList =
            List<String>.from(userData?['friends'] ?? []);

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('events').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final now = DateTime.now();
            final events = snapshot.data!.docs;
            final filteredEvents = events.where((event) {
              final eventData = event.data() as Map<String, dynamic>;
              final String visibility = eventData['visibility'] ?? 'Public';
              final String creatorId = eventData['creatorId'];

              // Parse event date and time
              final eventDate = (eventData['date'] as Timestamp).toDate();
              final eventTime = eventData['time'] as String;
              final fullEventDateTime = _parseEventTime(eventDate, eventTime);

              // Only show future events
              if (fullEventDateTime.isAfter(now)) {
                // Check visibility conditions
                if (visibility == 'Public' ||
                    (visibility == 'Visible to all friends' &&
                        friendsList.contains(creatorId))) {
                  return true;
                }
              }
              return false;
            }).toList();

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                // Sort events by soonest expiring first
                filteredEvents.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;

                  final aDate = (aData['date'] as Timestamp).toDate();
                  final aTime = aData['time'] as String;
                  final aFullDateTime = _parseEventTime(aDate, aTime);

                  final bDate = (bData['date'] as Timestamp).toDate();
                  final bTime = bData['time'] as String;
                  final bFullDateTime = _parseEventTime(bDate, bTime);

                  return aFullDateTime.compareTo(bFullDateTime);
                });

                final event = filteredEvents[index];
                return EventCard(
                  eventId: event.id,
                  eventData: event.data() as Map<String, dynamic>,
                  user: user,
                  onDelete: () => _deleteEvent(event.id, context),
                  onViewDetails: () => _goToEventDetailsPage(context, event.id),
                );
              },
            );
          },
        );
      },
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void _showCalendarSubscriptionLink(BuildContext context) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final calendarId = doc.data()?['calendarId'];
      print('Calendar ID: $calendarId');
      if (calendarId == null || calendarId == 'none') {
        _showDialog(context, 'No Calendar Found',
            'You do not have a calendar set up yet.');
        return;
      }

      final iCalLink =
          "https://calendar.google.com/calendar/ical/$calendarId/public/basic.ics";

      _showDialog(
        context,
        'Subscribe to Your Calendar',
        'To subscribe to your events:\n\n'
            '1️⃣ Open **Google Calendar**\n'
            '2️⃣ Click on **"Other calendars"** in the left panel\n'
            '3️⃣ Select **"From URL"**\n'
            '4️⃣ Paste this link:\n\n'
            '**$iCalLink**\n\n'
            '5️⃣ Click **"Add calendar"** ✅\n\n'
            'Your events will now automatically sync!',
      );
    } catch (e) {
      _showDialog(context, 'Error', 'Failed to retrieve calendar link.');
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SelectableText(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _createEvent(
      BuildContext context, String userId, FirestoreService firestoreService) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController nameController = TextEditingController();
        final TextEditingController descriptionController =
            TextEditingController();
        final TextEditingController locationController =
            TextEditingController();
        DateTime? selectedDate;
        TimeOfDay? selectedTime;
        String selectedVisibility = 'Public';
        final List<String> visibilityOptions = [
          'Public',
          'Visible to all friends',
          'Visible to a particular group'
        ];
        String? selectedGroup; // For specific group selection

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Create Event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Event Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(labelText: 'Location'),
                    ),
                    SizedBox(height: 10),

                    // Date Picker
                    ListTile(
                      title: Text(selectedDate == null
                          ? 'Select Date'
                          : 'Date: ${selectedDate!.toLocal()}'.split(' ')[0]),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                    ),

                    // Time Picker
                    ListTile(
                      title: Text(selectedTime == null
                          ? 'Select Time'
                          : 'Time: ${selectedTime!.format(context)}'),
                      trailing: Icon(Icons.access_time),
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            selectedTime = pickedTime;
                          });
                        }
                      },
                    ),

                    // Visibility Dropdown
                    DropdownButton<String>(
                      value: selectedVisibility,
                      onChanged: (newValue) {
                        setState(() {
                          selectedVisibility = newValue!;
                        });
                      },
                      items: visibilityOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                    ),

                    // Group Selection (only if "Visible to a particular group" is chosen)
                    if (selectedVisibility == 'Visible to a particular group')
                      TextField(
                        decoration:
                            InputDecoration(labelText: 'Enter Group Name'),
                        onChanged: (value) {
                          selectedGroup = value;
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        locationController.text.isNotEmpty &&
                        selectedDate != null &&
                        selectedTime != null &&
                        (selectedVisibility !=
                                'Visible to a particular group' ||
                            selectedGroup != null)) {
                      // Convert TimeOfDay to a string format
                      final formattedTime = selectedTime!.format(context);

                      firestoreService.createEvent(
                        nameController.text,
                        descriptionController.text,
                        locationController.text,
                        selectedDate!,
                        formattedTime,
                        userId,
                        selectedVisibility,
                        selectedGroup ?? '',
                      );
                      Navigator.pop(context);
                    } else {
                      // Show error if fields are missing
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in all fields')),
                      );
                    }
                  },
                  child: Text('Create'),
                ),
              ],
            );
          },
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

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final calendarId = userDoc.data()?['calendarId'];
      if (calendarId == null) return;

      final calendarService = CalendarService();
      final gcalEventId = await calendarService.addEventToPrivateCalendar(
        calendarId,
        eventName,
        eventStartTime,
        eventEndTime,
      );

      await _firestore.collection('users').doc(userId).update({
        'gcalEventMappings.$eventId': gcalEventId,
      });
    } else {
      await eventDoc.update({
        'accepted': FieldValue.arrayRemove([userId]),
      });

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final calendarId = userDoc.data()?['calendarId'];
      final gcalEventId = userDoc.data()?['gcalEventMappings']?[eventId];

      if (calendarId != null && gcalEventId != null) {
        final calendarService = CalendarService();
        await calendarService.removeEventFromPrivateCalendar(
            calendarId, gcalEventId);

        await _firestore.collection('users').doc(userId).update({
          'gcalEventMappings.$eventId': FieldValue.delete(),
        });
      }
    }
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
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final calendarId = userDoc.data()?['calendarId'];
      final gcalEventId = userDoc.data()?['gcalEventMappings']?[eventId];

      if (calendarId != null && gcalEventId != null) {
        final calendarService = CalendarService();
        await calendarService.removeEventFromPrivateCalendar(
            calendarId, gcalEventId);

        await _firestore.collection('users').doc(user.uid).update({
          'gcalEventMappings.$eventId': FieldValue.delete(),
        });
      }

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

class EventDetailsPage extends StatelessWidget {
  final String eventId;
  final User user;

  EventDetailsPage({required this.eventId, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _CommentSection(eventId: eventId, user: user),
          ),
        ],
      ),
    );
  }
}

class _CommentSection extends StatefulWidget {
  final String eventId;
  final User user;

  _CommentSection({required this.eventId, required this.user});

  @override
  __CommentSectionState createState() => __CommentSectionState();
}

class __CommentSectionState extends State<_CommentSection> {
  final _commentController = TextEditingController();

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    final dateTime = timestamp.toDate();
    return '${dateTime.toLocal()}'.split('.')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .doc(widget.eventId)
              .collection('comments')
              .orderBy('timestamp')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final comments = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index].data() as Map<String, dynamic>;
                final userName = comment['userName'] ?? 'Anonymous';
                final message = comment['message'] ?? '[No message]';
                final timestamp = comment['timestamp'] as Timestamp?;

                return ListTile(
                  title: Text('$userName (${_formatTimestamp(timestamp)})'),
                  subtitle: Text(message),
                );
              },
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(labelText: 'Write a comment...'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  final commentText = _commentController.text;
                  if (commentText.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('events')
                        .doc(widget.eventId)
                        .collection('comments')
                        .add({
                      'userName': widget.user.displayName ?? 'Anonymous',
                      'message':
                          commentText.isNotEmpty ? commentText : '[No message]',
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    _commentController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
