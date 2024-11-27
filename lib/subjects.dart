import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  _SubjectsPageState createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final String apiUrl = 'http://localhost:3000/subjects';
  List<Map<String, dynamic>> subjects = [];
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          subjects = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showError('Failed to fetch subjects. Please try again later.');
      }
    } catch (e) {
      showError('Error fetching subjects: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addSubject() async {
    final String name = nameController.text.trim();
    final String code = codeController.text.trim();
    final String department = departmentController.text.trim();
    final String description = descriptionController.text.trim();

    if (name.isEmpty || code.isEmpty || department.isEmpty || description.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final newSubject = {
        'subject_name': name,
        'subject_code': code,
        'department': department,
        'description': description,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newSubject),
      );

      if (response.statusCode == 201) {
        fetchSubjects();
        Navigator.pop(context);
      } else {
        showError('Failed to add subject.');
      }
    } catch (e) {
      showError('Error adding subject. Please try again.');
    }
  }

  Future<void> updateSubject(String id) async {
    final String name = nameController.text.trim();
    final String code = codeController.text.trim();
    final String department = departmentController.text.trim();
    final String description = descriptionController.text.trim();

    if (name.isEmpty || code.isEmpty || department.isEmpty || description.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final updatedSubject = {
        'subject_name': name,
        'subject_code': code,
        'department': department,
        'description': description,
      };

      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedSubject),
      );

      if (response.statusCode == 200) {
        fetchSubjects();
        Navigator.pop(context);
      } else {
        showError('Failed to update subject.');
      }
    } catch (e) {
      showError('Error updating subject. Please try again.');
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        fetchSubjects();
      } else {
        showError('Failed to delete subject.');
      }
    } catch (e) {
      showError('Error deleting subject: $e');
    }
  }

  void showSubjectDialog({Map<String, dynamic>? subject}) {
    final isEditing = subject != null;

    if (isEditing) {
      nameController.text = subject!['subject_name'];
      codeController.text = subject['subject_code'];
      departmentController.text = subject['department'];
      descriptionController.text = subject['description'];
    } else {
      nameController.clear();
      codeController.clear();
      departmentController.clear();
      descriptionController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(nameController, 'Subject Name'),
                _buildTextField(codeController, 'Subject Code'),
                _buildTextField(departmentController, 'Department'),
                _buildTextField(descriptionController, 'Description'),
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
                  ? updateSubject(subject!['id'])
                  : addSubject(),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
        title: const Text('Subjects'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : subjects.isEmpty
              ? const Center(
                  child: Text(
                    'No subjects available. Add a new subject!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        title: Text(subject['subject_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(subject['description']),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => showSubjectDialog(subject: subject),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteSubject(subject['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSubjectDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
