/*
-This converts a timestamp object into a string

example
if the input timestamp represents: July 24, 2024, 12:00

the function will return string : "2024-07-24 13:30"
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimestamp(Timestamp timestap) {
  DateTime dateTime = timestap.toDate();
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}
