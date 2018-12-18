import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final int id;
  final String name;
  final DateTime date;
  final String description;
  final String img;
  final String prize;
  final DocumentReference reference;

  Event.fromMap(Map<dynamic, dynamic> map, {this.reference})
      : assert(map['id'] != null),
        id = map['id'],
        date = map['date'],
        name = map['name'],
        prize = map['prize'],
        img = map['img'],
        description = map['description'];

  Event.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Event<$id|$name|$date>";
}
