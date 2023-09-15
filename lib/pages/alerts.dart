import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AlertsPage extends StatefulWidget {
  const AlertsPage({Key? key}) : super(key: key);

  @override
  _AlertsPageState createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final List<Alert> alerts = [];
  final TextEditingController alertNameController = TextEditingController();
  final DateFormat dateFormat = DateFormat.yMd();
  final DateFormat timeFormat = DateFormat.jm();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _loadAlertsFromLocalStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Use your back icon here
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        title: Text("Alerts"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: alertNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter alert name',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  icon: Icon(Icons.calendar_today),
                ),
                IconButton(
                  onPressed: () {
                    _selectTime(context);
                  },
                  icon: Icon(Icons.access_time),
                ),
                IconButton(
                  onPressed: () {
                    _addAlert();
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return ListTile(
                  leading: Checkbox(
                    value: alert.isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        alert.isChecked = value ?? false;
                        _saveAlertsToLocalStorage();
                      });
                    },
                  ),
                  title: Text(alert.name),
                  subtitle: Text(
                      'Date: ${dateFormat.format(alert.dateTime)}\nTime: ${timeFormat.format(alert.dateTime)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        alerts.removeAt(index);
                        _saveAlertsToLocalStorage();
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  void _addAlert() {
    final DateTime alertDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final String alertName = alertNameController.text;

    if (alertName.isNotEmpty) {
      setState(() {
        alerts.add(Alert(name: alertName, dateTime: alertDateTime));
        alertNameController.clear();
        _saveAlertsToLocalStorage();
      });
    }
  }

  Future<void> _saveAlertsToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final alertsData = alerts.map((alert) => alert.toJson()).toList();
    final alertsDataStrings =
        alertsData.map((alertData) => json.encode(alertData)).toList();
    await prefs.setStringList('alerts', alertsDataStrings);
  }

  Future<void> _loadAlertsFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final alertsDataStrings = prefs.getStringList('alerts');
    if (alertsDataStrings != null) {
      final alertsData = alertsDataStrings
          .map((alertDataString) => json.decode(alertDataString))
          .toList();
      final loadedAlerts =
          alertsData.map((alertData) => Alert.fromJson(alertData)).toList();
      setState(() {
        alerts.clear();
        alerts.addAll(loadedAlerts);
      });
    }
  }
}

class Alert {
  final String name;
  final DateTime dateTime;
  bool isChecked;

  Alert({
    required this.name,
    required this.dateTime,
    this.isChecked = false,
  });

  // Define the toJson method to convert Alert to a JSON-serializable map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateTime': dateTime.toIso8601String(), // Convert DateTime to a string.
      'isChecked': isChecked,
    };
  }

  // Define a factory method to create an Alert from a JSON map.
  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      name: json['name'],
      dateTime: DateTime.parse(json['dateTime']),
      isChecked: json['isChecked'],
    );
  }
}
