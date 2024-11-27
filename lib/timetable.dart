import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final String apiUrl = 'http://localhost:3000/sessions';
  List<Map<String, dynamic>> sessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          sessions = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showError('Failed to fetch sessions. Please try again later.');
      }
    } catch (e) {
      showError('Error fetching sessions: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<String> _timeSlots() {
    return [
      '08:00 - 09:00',
      '09:00 - 10:00',
      '10:00 - 11:00',
      '11:00 - 12:00',
      '12:00 - 13:00',
      '13:00 - 14:00',
      '14:00 - 15:00',
    ];
  }

  String _getDayFromDate(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      default:
        return '';
    }
  }

  Widget _getSessionForDayAndTime(String day, String time) {
    final session = sessions.firstWhere(
      (session) {
        final sessionDate = DateTime.parse(session['session_date']);
        final sessionDay = _getDayFromDate(sessionDate);
        final sessionTime = session['start_time'];

        return sessionDay == day && sessionTime == time.split(' - ')[0];
      },
      orElse: () => {},
    );

    if (session.isEmpty) {
      return const Text('No session');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject: ${session['subject_id']}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 4),
        _buildCard('Teacher', session['teacher_id']),
        SizedBox(height: 4),
        _buildCard('Room', session['room_id']),
      ],
    );
  }

  // Create a card-like structure for both teacher and room
  Widget _buildCard(String label, String value) {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              label == 'Teacher' ? Icons.person : Icons.room,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            Text(
              '$label: $value',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                          width: 1,
                        ),
                        columnWidths: const {
                          0: FixedColumnWidth(120),
                          1: FixedColumnWidth(120),
                          2: FixedColumnWidth(120),
                          3: FixedColumnWidth(120),
                          4: FixedColumnWidth(120),
                          5: FixedColumnWidth(120),
                          6: FixedColumnWidth(120),
                        },
                        children: [
                          // Table Header (Days)
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            children: [
                              const TableCell(
                                  child: Center(
                                      child: Text(
                                'Time',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))),
                              for (String day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'])
                                TableCell(
                                  child: Center(
                                    child: Text(
                                      day,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          // Table rows for each time slot
                          for (String time in _timeSlots())
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                              ),
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Center(
                                      child: Text(
                                        time,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                                for (String day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'])
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: _getSessionForDayAndTime(day, time),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
