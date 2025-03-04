import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarService {
  final _scopes = [CalendarApi.calendarScope];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CalendarApi> _getCalendarApi() async {
    final credentialsJson =
        await rootBundle.loadString('/Users/leila/Documents/secrets/herd-aad12-6627b3250dc9.json');
    final credentials =
        auth.ServiceAccountCredentials.fromJson(credentialsJson);
    final client = await auth.clientViaServiceAccount(credentials, _scopes);
    return CalendarApi(client);
  }

  Future<String> _createCalendar(String userEmail) async {
    final calendarApi = await _getCalendarApi();
    final calendar = Calendar()
      ..summary = "Private Events for $userEmail"
      ..timeZone = "UTC";

    final createdCalendar = await calendarApi.calendars.insert(calendar);
    final calendarId = createdCalendar.id!;

    final aclRule = AclRule()
      ..scope = (AclRuleScope()
        ..type = "user"
        ..value = userEmail)
      ..role = "reader";

    await calendarApi.acl.insert(aclRule, calendarId);
    return calendarId;
  }

  String _getICalSubscriptionLink(String calendarId) {
    return "https://calendar.google.com/calendar/ical/$calendarId/public/basic.ics";
  }

  Future<String> ensureUserHasCalendar(String userId, String userEmail) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    String calendarId;

    if (userDoc.exists &&
        userDoc.data()?['calendarLink'] != null &&
        userDoc.data()?['calendarLink'] != "None") {
      calendarId = userDoc.data()?['calendarId'];
    } else {
      calendarId = await _createCalendar(userEmail);
      await _firestore.collection('users').doc(userId).set({
        'calendarId': calendarId,
        'calendarLink': _getICalSubscriptionLink(calendarId),
      }, SetOptions(merge: true));
    }

    return _getICalSubscriptionLink(calendarId);
  }

  Future<String> addEventToPrivateCalendar(
      String calendarId, String summary, DateTime start, DateTime end) async {
    final calendarApi = await _getCalendarApi();
    final event = Event()
      ..summary = summary
      ..start = EventDateTime(dateTime: start.toUtc())
      ..end = EventDateTime(dateTime: end.toUtc());

    final createdEvent = await calendarApi.events.insert(event, calendarId);
    return createdEvent.id!;
  }

  Future<void> removeEventFromPrivateCalendar(
      String calendarId, String eventId) async {
    final calendarApi = await _getCalendarApi();
    await calendarApi.events.delete(calendarId, eventId);
  }
}
