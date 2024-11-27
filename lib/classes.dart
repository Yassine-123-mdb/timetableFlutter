import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  _ClassesPageState createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  final String apiUrl = 'http://localhost:3000/classes';
  List<Map<String, dynamic>> classes = [];
  bool isLoading = true;

  final TextEditingController classNameController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController studentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          classes = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showError('Failed to fetch classes. Please try again later.');
      }
    } catch (e) {
      showError('Error fetching classes: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addClass() async {
    final String className = classNameController.text.trim();
    final String subject = subjectController.text.trim();
    final String students = studentsController.text.trim();

    if (className.isEmpty || subject.isEmpty || students.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final newClass = {
        'class_name': className,
        'subject_id': subject,
        'students': students.split(','),
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newClass),
      );

      if (response.statusCode == 201) {
        fetchClasses();
        Navigator.pop(context);
      } else {
        showError('Failed to add class.');
      }
    } catch (e) {
      showError('Error adding class. Please try again.');
    }
  }

  Future<void> updateClass(String id) async {
    final String className = classNameController.text.trim();
    final String subject = subjectController.text.trim();
    final String students = studentsController.text.trim();

    if (className.isEmpty || subject.isEmpty || students.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final updatedClass = {
        'class_name': className,
        'subject_id': subject,
        'students': students.split(','),
      };

      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedClass),
      );

      if (response.statusCode == 200) {
        fetchClasses();
        Navigator.pop(context);
      } else {
        showError('Failed to update class.');
      }
    } catch (e) {
      showError('Error updating class. Please try again.');
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        fetchClasses();
      } else {
        showError('Failed to delete class.');
      }
    } catch (e) {
      showError('Error deleting class: $e');
    }
  }

  void showClassDialog({Map<String, dynamic>? classData}) {
    final isEditing = classData != null;

    if (isEditing) {
      classNameController.text = classData!['class_name'];
      subjectController.text = classData['subject_id'];
      studentsController.text = classData['students'].join(',');
    } else {
      classNameController.clear();
      subjectController.clear();
      studentsController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Class' : 'Add Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(controller: classNameController, label: 'Class Name'),
                _buildTextField(controller: subjectController, label: 'Subject ID'),
                _buildTextField(controller: studentsController, label: 'Students (comma separated)'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => isEditing
                  ? updateClass(classData!['id'])
                  : addClass(),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : classes.isEmpty
              ? const Center(
                  child: Text(
                    'No classes available. Add a new class!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final classData = classes[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        title: Text(
                          classData['class_name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Subject ID: ${classData['subject_id']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => showClassDialog(classData: classData),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteClass(classData['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showClassDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
