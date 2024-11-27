import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  _StudentsPageState createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final String apiUrl = 'http://localhost:3000/students';
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStudents(); // Charger la liste des étudiants au démarrage
  }

  // Fonction pour récupérer les étudiants depuis l'API
  Future<void> fetchStudents() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          students = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showError('Échec de la récupération des étudiants. Essayez à nouveau plus tard.');
      }
    } catch (e) {
      showError('Erreur lors de la récupération des étudiants: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Fonction pour ajouter un étudiant
  Future<void> addStudent() async {
    final String firstName = firstNameController.text.trim();
    final String lastName = lastNameController.text.trim();
    final String email = emailController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      showError('Veuillez remplir tous les champs.');
      return;
    }

    try {
      final newStudent = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newStudent),
      );

      if (response.statusCode == 201) {
        fetchStudents(); // Mettre à jour la liste après l'ajout
        Navigator.pop(context);
      } else {
        showError('Échec de l\'ajout de l\'étudiant.');
      }
    } catch (e) {
      showError('Erreur lors de l\'ajout de l\'étudiant. Veuillez réessayer.');
    }
  }

  // Fonction pour mettre à jour les informations d'un étudiant
  Future<void> updateStudent(String id) async {
    final String firstName = firstNameController.text.trim();
    final String lastName = lastNameController.text.trim();
    final String email = emailController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      showError('Veuillez remplir tous les champs.');
      return;
    }

    try {
      final updatedStudent = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      };

      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedStudent),
      );

      if (response.statusCode == 200) {
        fetchStudents(); // Mettre à jour la liste après la mise à jour
        Navigator.pop(context);
      } else {
        showError('Échec de la mise à jour de l\'étudiant.');
      }
    } catch (e) {
      showError('Erreur lors de la mise à jour de l\'étudiant. Veuillez réessayer.');
    }
  }

  // Fonction pour supprimer un étudiant
  Future<void> deleteStudent(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        fetchStudents(); // Mettre à jour la liste après la suppression
      } else {
        showError('Échec de la suppression de l\'étudiant.');
      }
    } catch (e) {
      showError('Erreur lors de la suppression de l\'étudiant: $e');
    }
  }

  // Fonction pour afficher le dialogue d'ajout ou de mise à jour de l'étudiant
  void showStudentDialog({Map<String, dynamic>? studentData}) {
    final isEditing = studentData != null;

    if (isEditing) {
      firstNameController.text = studentData!['first_name'];
      lastNameController.text = studentData['last_name'];
      emailController.text = studentData['email'];
    } else {
      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Modifier l\'étudiant' : 'Ajouter un étudiant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => isEditing
                  ? updateStudent(studentData!['id'])
                  : addStudent(),
              child: Text(isEditing ? 'Mettre à jour' : 'Ajouter'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour afficher les erreurs sous forme de SnackBar
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun étudiant disponible. Ajoutez un nouvel étudiant!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final studentData = students[index];
                    return Card(
                      child: ListTile(
                        title: Text('${studentData['first_name']} ${studentData['last_name']}'),
                        subtitle: Text(studentData['email']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showStudentDialog(studentData: studentData),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteStudent(studentData['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showStudentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
