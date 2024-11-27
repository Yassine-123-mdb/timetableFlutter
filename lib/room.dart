import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  _RoomsPageState createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final String apiUrl = 'http://localhost:3000/rooms';
  List<Map<String, dynamic>> rooms = [];
  bool isLoading = true;

  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController buildingController = TextEditingController();
  final TextEditingController floorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }
  
  Future<void> updateRoom(String id) async {
  final String roomName = roomNameController.text.trim();
  final String capacity = capacityController.text.trim();
  final String building = buildingController.text.trim();
  final String floor = floorController.text.trim();

  if (roomName.isEmpty || capacity.isEmpty || building.isEmpty || floor.isEmpty) {
    showError('Please fill all fields.');
    return;
  }

  try {
    final updatedRoom = {
      'room_name': roomName,
      'capacity': int.parse(capacity),
      'building': building,
      'floor': int.parse(floor),
    };

    final response = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedRoom),
    );

    if (response.statusCode == 200) {
      fetchRooms();
      Navigator.pop(context);
    } else {
      showError('Failed to update room.');
    }
  } catch (e) {
    showError('Error updating room. Ensure capacity and floor are valid numbers.');
  }
}

  Future<void> fetchRooms() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          rooms = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showError('Failed to fetch rooms. Please try again later.');
      }
    } catch (e) {
      showError('Error fetching rooms: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addRoom() async {
    final String roomName = roomNameController.text.trim();
    final String capacity = capacityController.text.trim();
    final String building = buildingController.text.trim();
    final String floor = floorController.text.trim();

    if (roomName.isEmpty || capacity.isEmpty || building.isEmpty || floor.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final newRoom = {
        'room_name': roomName,
        'capacity': int.parse(capacity),
        'building': building,
        'floor': int.parse(floor),
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newRoom),
      );

      if (response.statusCode == 201) {
        fetchRooms();
        Navigator.pop(context);
      } else {
        showError('Failed to add room.');
      }
    } catch (e) {
      showError('Error adding room. Ensure capacity and floor are valid numbers.');
    }
  }

  Future<void> deleteRoom(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        fetchRooms();
      } else {
        showError('Failed to delete room.');
      }
    } catch (e) {
      showError('Error deleting room: $e');
    }
  }

  void showRoomDialog({Map<String, dynamic>? room}) {
    final isEditing = room != null;

    if (isEditing) {
      roomNameController.text = room?['room_name'] ?? '';
      capacityController.text = room?['capacity']?.toString() ?? '';
      buildingController.text = room?['building'] ?? '';
      floorController.text = room?['floor']?.toString() ?? '';
    } else {
      roomNameController.clear();
      capacityController.clear();
      buildingController.clear();
      floorController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Room' : 'Add Room'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(controller: roomNameController, label: 'Room Name'),
                _buildTextField(controller: capacityController, label: 'Capacity', isNumeric: true),
                _buildTextField(controller: buildingController, label: 'Building'),
                _buildTextField(controller: floorController, label: 'Floor', isNumeric: true),
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
                  ? updateRoom(room!['id'])
                  : addRoom(),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
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
        title: const Text('Rooms'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rooms.isEmpty
              ? const Center(
                  child: Text(
                    'No rooms available. Add a new room!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        title: Text(
                          room['room_name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            'Capacity: ${room['capacity']}\nBuilding: ${room['building']}\nFloor: ${room['floor']}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => showRoomDialog(room: room),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteRoom(room['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showRoomDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
