import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TeachersPage extends StatefulWidget {
  const TeachersPage({super.key});

  @override
  _TeachersPageState createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  final String apiUrl = 'http://localhost:3000/teachers';
  List<Map<String, dynamic>> teachers = [];
  bool isLoading = true;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          teachers = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showError('Failed to fetch teachers. Please try again later.');
      }
    } catch (e) {
      showError('Error fetching teachers: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addTeacher() async {
    final String firstName = firstNameController.text.trim();
    final String lastName = lastNameController.text.trim();
    final String email = emailController.text.trim();
    final String department = departmentController.text.trim();
    final String phone = phoneController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || department.isEmpty || phone.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final newTeacher = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'department': department,
        'phone': phone,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newTeacher),
      );

      if (response.statusCode == 201) {
        fetchTeachers();
        Navigator.pop(context);
      } else {
        showError('Failed to add teacher.');
      }
    } catch (e) {
      showError('Error adding teacher: $e');
    }
  }

  Future<void> updateTeacher(String id) async {
    final String firstName = firstNameController.text.trim();
    final String lastName = lastNameController.text.trim();
    final String email = emailController.text.trim();
    final String department = departmentController.text.trim();
    final String phone = phoneController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || department.isEmpty || phone.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final updatedTeacher = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'department': department,
        'phone': phone,
      };

      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedTeacher),
      );

      if (response.statusCode == 200) {
        fetchTeachers();
        Navigator.pop(context);
      } else {
        showError('Failed to update teacher.');
      }
    } catch (e) {
      showError('Error updating teacher: $e');
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        fetchTeachers();
      } else {
        showError('Failed to delete teacher.');
      }
    } catch (e) {
      showError('Error deleting teacher: $e');
    }
  }

  void showTeacherDialog({Map<String, dynamic>? teacher}) {
    final isEditing = teacher != null;

    if (isEditing) {
      firstNameController.text = teacher?['first_name'] ?? '';
      lastNameController.text = teacher?['last_name'] ?? '';
      emailController.text = teacher?['email'] ?? '';
      departmentController.text = teacher?['department'] ?? '';
      phoneController.text = teacher?['phone'] ?? '';
    } else {
      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
      departmentController.clear();
      phoneController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(isEditing ? 'Edit Teacher' : 'Add Teacher'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(firstNameController, 'First Name'),
                _buildTextField(lastNameController, 'Last Name'),
                _buildTextField(emailController, 'Email', keyboardType: TextInputType.emailAddress),
                _buildTextField(departmentController, 'Department'),
                _buildTextField(phoneController, 'Phone', keyboardType: TextInputType.phone),
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
                  ? updateTeacher(teacher!['id'])
                  : addTeacher(),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
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
        title: const Text('Teachers'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : teachers.isEmpty
              ? const Center(
                  child: Text(
                    'No teachers available. Add a new teacher!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = teachers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        title: Text(
                          '${teacher['first_name']} ${teacher['last_name']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${teacher['email']}'),
                            Text('Department: ${teacher['department']}'),
                            Text('Phone: ${teacher['phone']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showTeacherDialog(teacher: teacher),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteTeacher(teacher['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTeacherDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
