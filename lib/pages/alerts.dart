import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AlertsPage extends StatefulWidget {
  @override
  _AlertsPageState createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final TextEditingController _alertNameController = TextEditingController();
  final CollectionReference _alertsCollection =
      FirebaseFirestore.instance.collection('alerts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alerts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _alertsCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          final alerts = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Alert(
              id: doc.id,
              name: data['name'],
              dateTime: (data['dateTime'] as Timestamp).toDate(),
            );
          }).toList();

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return ListTile(
                title: Text(alert.name),
                subtitle: Text(
                  'Date: ${DateFormat.yMd().add_jm().format(alert.dateTime)}',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteAlert(alert.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAlertDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddAlertDialog(BuildContext context) async {
    final DateTime? selectedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (selectedDateTime != null) {
      final String? alertName = await showDialog(
        context: context,
        builder: (context) => _buildAlertDialog(context, selectedDateTime),
      );

      if (alertName != null && alertName.isNotEmpty) {
        _addAlert(alertName, selectedDateTime);
      } else {
        // Handle the case where the user cancels the dialog.
        // You can display a message or take appropriate action.
      }
    }
  }

  AlertDialog _buildAlertDialog(
      BuildContext context, DateTime selectedDateTime) {
    final TextEditingController alertNameController = TextEditingController();

    return AlertDialog(
      title: Text('Create Alert'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: alertNameController,
            decoration: InputDecoration(labelText: 'Alert Name'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(); // Cancel the dialog.
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            final String alertName = alertNameController.text.trim();
            if (alertName.isNotEmpty) {
              Navigator.of(context).pop(alertName); // Return the alert name.
            }
          },
        ),
      ],
    );
  }

  void _addAlert(String name, DateTime dateTime) async {
    await _alertsCollection.add({
      'name': name,
      'dateTime': dateTime.toUtc(),
    });
  }

  void _deleteAlert(String alertId) async {
    await _alertsCollection.doc(alertId).delete();
  }

  @override
  void dispose() {
    _alertNameController.dispose();
    super.dispose();
  }
}

class Alert {
  final String id;
  final String name;
  final DateTime dateTime;

  Alert({
    required this.id,
    required this.name,
    required this.dateTime,
  });
}
