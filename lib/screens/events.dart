import 'package:cerebro_flutter/models/record.dart';
import 'package:cerebro_flutter/models/user.dart';
import 'package:cerebro_flutter/utils/authManagement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  User curUser;

  @override
  void initState() {
    User user = AuthManager().getCurrentUser();
    if (user != null) {
      setState(() {
        curUser = user;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events List'),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: FlatButton(
              onPressed: () {
                AuthManager().signOut();
                // Doing Pop and Push for the smooth closing animation
                Navigator.of(context).popAndPushNamed('/login');
              },
              child: Text('Logout'),
            ),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final _event = Event.fromSnapshot(data);

    String _date(DateTime timestamp) {
      return DateFormat.jm().add_yMMMd().format(timestamp);
    }

    return Padding(
      key: ValueKey(_event.id),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        child: Card(
          elevation: 5.0,
          child: ListTile(
            leading: Image.network(
              _event.img,
              width: 60,
              height: 60,
            ),
            title: Text(
              _event.name,
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            subtitle: Text(_date(_event.date)),
            trailing: IconButton(
              icon: Icon(Icons.add_circle_outline),
              iconSize: 30.0,
              onPressed: () {
                // TODO: using the event id, register the user
              },
            ),
            onTap: () => print(_event),
          ),
        ),
      ),
    );
  }
}
