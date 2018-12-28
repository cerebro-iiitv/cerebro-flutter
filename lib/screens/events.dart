import 'package:cached_network_image/cached_network_image.dart';
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
  Map registeredEvents = Map();
  final TextEditingController teamNameController = TextEditingController();

  Future<Null> fetchRegistered() async {
    Firestore.instance
        .collection(curUser.id)
        .document('events')
        .collection('registered')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      if (snapshot.documents != null) {
        var documents = snapshot.documents;
        for (final elem in documents) {
          setState(() {
            registeredEvents.putIfAbsent(
                elem.documentID, () => elem.data['isRegistered']);
          });
        }
      }
    });
  }

  @override
  void initState() {
    User user = AuthManager().getCurrentUser();
    if (user != null) {
      setState(() {
        curUser = user;
      });
      fetchRegistered();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events List'),
        actions: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(curUser.imgURL),
                ),
                onTap: () {
                  // TODO: Implement Hero animation to go to Profile page
                  print('Go to Profile');
                },
                onLongPress: () {},
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: GestureDetector(
                  child: Icon(Icons.exit_to_app, size: 30.0),
                  onTap: () {
                    AuthManager().signOut();
                    // Doing Pop and Push for the smooth closing animation
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                ),
              )
            ],
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

  // Prompt to show that team should be added or not
  void showTeamPromptDialog(
      Event event, BuildContext context, BuildContext scContext) {
    showDialog(
        context: context,
        builder: (BuildContext alertContext) {
          return AlertDialog(
            title: Text("Confirm Team"),
            content:
                Text("Would you like to add team " + teamNameController.text),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Firestore.instance
                      .collection(event.name)
                      .document(teamNameController.text)
                      .setData({
                    'members': [curUser.id]
                  }).then((_) {
                    print("Team added");
                    Firestore.instance
                        .collection(curUser.id)
                        .document('events')
                        .collection('registered')
                        .document(event.name)
                        .setData({'isRegistered': true}).whenComplete(() {
                      print('Success');
                      setState(() {
                        registeredEvents[event.name] = true;
                      });
                    });
                    displaySnackBar(scContext, "Registered for " + event.name);
                    Navigator.pop(alertContext);
                  });
                },
                child: Text("Submit"),
              ),
            ],
          );
        });
  }

  // Check if team exists or not
  void checkTeamName(
      Event event, BuildContext context, BuildContext scContext) {
    Firestore.instance
        .collection(event.name)
        .document(teamNameController.text)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.data == null) {
        // Team not found
        Navigator.pop(context);
        // Prompt user to add team
        showTeamPromptDialog(event, context, scContext);
      } else {
        // Team found
        print(doc.data);
        var oldList = doc.data['members'].toList();
        bool alreadyHave = false;
        for (final memb in oldList) {
          if (memb == curUser.id) {
            alreadyHave = true;
            break;
          }
        }
        if (!alreadyHave) oldList.add(curUser.id);
        Firestore.instance
            .collection(event.name)
            .document(teamNameController.text)
            .updateData({'members': oldList}).then((_) {
          Firestore.instance
              .collection(curUser.id)
              .document('events')
              .collection('registered')
              .document(event.name)
              .setData({'isRegistered': true}).whenComplete(() {
            print('Success');
            setState(() {
              registeredEvents[event.name] = true;
            });
          });
          displaySnackBar(scContext, "Registered for " + event.name);
          print("User added");
          Navigator.pop(context);
        });
      }
    });
  }

  Widget teamNameForm(
      BuildContext context, Event event, BuildContext scContext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            labelText: "Enter Team Name",
            labelStyle: TextStyle(
              color: Colors.orange,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
          ),
          controller: teamNameController,
        ),
        SizedBox(
          height: 16.0,
        ),
        FlatButton(
          color: Colors.orange,
          onPressed: () {
            checkTeamName(event, context, scContext);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Submit"),
          ),
        )
      ],
    );
  }

  void displaySnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void handleEventReg(Event event, BuildContext context) {
    if (event.isTeam) {
      // Get User Team name
      showDialog(
          context: context,
          builder: (BuildContext formContext) {
            return SimpleDialog(
              contentPadding: EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              children: <Widget>[
                Container(
                  width: 300.0,
                  padding: EdgeInsets.all(16.0),
                  child: teamNameForm(formContext, event, context),
                ),
              ],
            );
          });
    } else {
      // Set Local Details for user use
      Firestore.instance
          .collection(curUser.id)
          .document('events')
          .collection('registered')
          .document(event.name)
          .setData({'isRegistered': true}).whenComplete(() {
        print('Success');
        setState(() {
          registeredEvents[event.name] = true;
        });
        displaySnackBar(context, "Registered for " + event.name);
      });

      // Set Global Event details for management use
      Firestore.instance
          .collection(event.name)
          .document()
          .setData(curUser.toJson());
    }
  }

  // Remove user from the team
  void removeUserFromTeam(
      Event event, String documentID, Map<String, dynamic> data) {
    var updateList = List();
    for (final elem in data['members']) {
      if (elem != curUser.id) {
        updateList.add(elem);
      }
    }
    if (updateList.isEmpty) {
      Firestore.instance
          .collection(event.name)
          .document(documentID)
          .delete()
          .whenComplete(() => print("Complete team deleted | No choice"));
    } else {
      Firestore.instance
          .collection(event.name)
          .document(documentID)
          .setData({'members': updateList}).whenComplete(
              () => print('User deleted from team'));
    }
  }

  // Unregister user from event
  void unregisterEvent(Event event, BuildContext context) {
    if (event.isTeam) {
      Firestore.instance
          .collection(event.name)
          .getDocuments()
          .then((querySnap) {
        var docs = querySnap.documents;
        for (final doc in docs) {
          for (final member in doc.data['members']) {
            if (member == curUser.id) {
              removeUserFromTeam(event, doc.documentID, doc.data);
            }
          }
        }
      });
    } else {
      // Remove Global Registration for event use
      Firestore.instance
          .collection(event.name)
          .where("id", isEqualTo: curUser.id)
          .snapshots()
          .listen((data) => data.documents.forEach((doc) {
                Firestore.instance
                    .collection(event.name)
                    .document(doc.documentID)
                    .delete()
                    .whenComplete(() {
                  print('Removed from event');
                });
              }));
    }
    // Remove Local Registration for user use
    Firestore.instance
        .collection(curUser.id)
        .document('events')
        .collection('registered')
        .document(event.name)
        .setData({'isRegistered': false}).whenComplete(() {
      print('Local Registration deleted');
      setState(() {
        registeredEvents[event.name] = false;
      });
      displaySnackBar(context, "Unregistered from " + event.name);
    });
  }

  void showUnregisterPrompt(Event event, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text('Unregister from ' + event.name),
            content:
                Text("Do you really want to unregister from " + event.name),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text("Cancel"),
              ),
              FlatButton(
                onPressed: () {
                  unregisterEvent(event, context);
                  Navigator.pop(dialogContext);
                },
                child: Text("Unregister"),
              ),
            ],
          );
        });
  }

  // Handle Event Card Icon
  Widget _eventBtn(Event event) {
    bool isRegistered;
    if (registeredEvents.containsKey(event.name)) {
      if (registeredEvents[event.name])
        isRegistered = true;
      else
        isRegistered = false;
    } else {
      isRegistered = false;
    }
    return AnimatedCrossFade(
      firstChild: Icon(
        Icons.add_circle_outline,
      ),
      secondChild: Icon(
        Icons.delete_outline,
      ),
      crossFadeState:
          isRegistered ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: Duration(milliseconds: 300),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final _event = Event.fromSnapshot(data);

    String _date(DateTime timestamp) {
      return DateFormat.jm().add_yMMMd().format(timestamp);
    }

    if (registeredEvents != null) {
      return Padding(
        key: ValueKey(_event.id),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          child: Card(
            elevation: 5.0,
            child: ListTile(
              leading: CachedNetworkImage(
                imageUrl: _event.img,
                placeholder: new CircularProgressIndicator(),
                errorWidget: new Icon(Icons.error),
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
                icon: _eventBtn(_event),
                iconSize: 30.0,
                onPressed: () {
                  if (registeredEvents.containsKey(_event.name)) {
                    if (registeredEvents[_event.name]) {
                      if (_event.date.difference(DateTime.now()).inDays <= 2)
                        displaySnackBar(
                            context, "Cannot Unregister from " + _event.name);
                      else {
                        showUnregisterPrompt(_event, context);
                      }
                    } else {
                      handleEventReg(_event, context);
                    }
                  } else {
                    handleEventReg(_event, context);
                  }
                },
              ),
              onTap: () => print(_event),
            ),
          ),
        ),
      );
    } else {
      return LinearProgressIndicator();
    }
  }
}
