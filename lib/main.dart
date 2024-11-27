import 'package:flutter/material.dart';
import '/auth/login_page.dart';
import '/auth/auth_utils.dart';
import 'room.dart';
import 'teachers.dart';
import 'subjects.dart';
import 'classes.dart';
import 'sessions.dart';
import 'students.dart';
import 'timetable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Button Navigator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/main': (context) =>  HomePage(),
      },
      home: FutureBuilder<bool>(
        future: isAuthenticated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == true) {
            return  HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key});  // Removed 'const' here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: _buttons.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 2.5, // Adjust height and width ratio for each button
          ),
          itemBuilder: (context, index) {
            final button = _buttons[index];
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => button.targetPage),
                  );
                },
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(button.icon, size: 30, color: Colors.blue.shade600),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          button.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // List of buttons to display
  final _buttons = [
    _Button('Rooms', Icons.room, const RoomsPage()),
    _Button('Teachers', Icons.person, const TeachersPage()),
    _Button('Subjects', Icons.book, const SubjectsPage()),
    _Button('Classes', Icons.class_, const ClassesPage()),
    _Button('Sessions', Icons.access_time, const SessionsPage()),
    _Button('Students', Icons.group, const StudentsPage()),
    _Button('Timetable', Icons.schedule, const TimetablePage()),
  ];
}

class _Button {
  final String title;
  final IconData icon;
  final Widget targetPage;

  _Button(this.title, this.icon, this.targetPage);
}
