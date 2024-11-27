import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  _SessionsPageState createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  final String apiUrl = 'http://localhost:3000/sessions';
  List<Map<String, dynamic>> sessions = [];
  bool isLoading = true;

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController teacherController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

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
        showError('Failed to fetch sessions.');
      }
    } catch (e) {
      showError('Error fetching sessions: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addSession() async {
    if (_validateInputs()) {
      final newSession = _buildSessionData();
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(newSession),
        );
        if (response.statusCode == 201) {
          fetchSessions();
          Navigator.pop(context);
        } else {
          showError('Failed to add session.');
        }
      } catch (e) {
        showError('Error adding session: $e');
      }
    }
  }

  Future<void> updateSession(String id) async {
    if (_validateInputs()) {
      final updatedSession = _buildSessionData();
      try {
        final response = await http.put(
          Uri.parse('$apiUrl/$id'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updatedSession),
        );
        if (response.statusCode == 200) {
          fetchSessions();
          Navigator.pop(context);
        } else {
          showError('Failed to update session.');
        }
      } catch (e) {
        showError('Error updating session: $e');
      }
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        fetchSessions();
      } else {
        showError('Failed to delete session.');
      }
    } catch (e) {
      showError('Error deleting session: $e');
    }
  }

  bool _validateInputs() {
    if (subjectController.text.trim().isEmpty ||
        teacherController.text.trim().isEmpty ||
        roomController.text.trim().isEmpty ||
        classController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        startTimeController.text.trim().isEmpty ||
        endTimeController.text.trim().isEmpty) {
      showError('Please fill all fields.');
      return false;
    }
    return true;
  }

  Map<String, String> _buildSessionData() {
    return {
      'subject_id': subjectController.text.trim(),
      'teacher_id': teacherController.text.trim(),
      'room_id': roomController.text.trim(),
      'class_id': classController.text.trim(),
      'session_date': dateController.text.trim(),
      'start_time': startTimeController.text.trim(),
      'end_time': endTimeController.text.trim(),
    };
  }

  void showSessionDialog({Map<String, dynamic>? sessionData}) {
    final isEditing = sessionData != null;

    if (isEditing) {
      subjectController.text = sessionData!['subject_id'];
      teacherController.text = sessionData['teacher_id'];
      roomController.text = sessionData['room_id'];
      classController.text = sessionData['class_id'];
      dateController.text = sessionData['session_date'];
      startTimeController.text = sessionData['start_time'];
      endTimeController.text = sessionData['end_time'];
    } else {
      _clearControllers();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Session' : 'Add Session'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildInputFields(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => isEditing
                  ? updateSession(sessionData!['id'])
                  : addSession(),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _clearControllers() {
    subjectController.clear();
    teacherController.clear();
    roomController.clear();
    classController.clear();
    dateController.clear();
    startTimeController.clear();
    endTimeController.clear();
  }

  List<Widget> _buildInputFields() {
    return [
      TextField(
        controller: subjectController,
        decoration: const InputDecoration(labelText: 'Subject ID'),
      ),
      TextField(
        controller: teacherController,
        decoration: const InputDecoration(labelText: 'Teacher ID'),
      ),
      TextField(
        controller: roomController,
        decoration: const InputDecoration(labelText: 'Room ID'),
      ),
      TextField(
        controller: classController,
        decoration: const InputDecoration(labelText: 'Class ID'),
      ),
      TextField(
        controller: dateController,
        decoration: const InputDecoration(labelText: 'Session Date (YYYY-MM-DD)'),
      ),
      TextField(
        controller: startTimeController,
        decoration: const InputDecoration(labelText: 'Start Time'),
      ),
      TextField(
        controller: endTimeController,
        decoration: const InputDecoration(labelText: 'End Time'),
      ),
    ];
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      backgroundColor: Colors.blue.shade600,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sessions.isEmpty
              ? const Center(
                  child: Text(
                    'No sessions available. Add a new session!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final sessionData = sessions[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          'Class: ${sessionData['class_id']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.book, size: 18, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text('Subject: ${sessionData['subject_id']}'),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.person, size: 18, color: Colors.green),
                                const SizedBox(width: 4),
                                Text('Teacher: ${sessionData['teacher_id']}'),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 18, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(
                                  'Date: ${sessionData['session_date']}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showSessionDialog(sessionData: sessionData),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteSession(sessionData['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSessionDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
