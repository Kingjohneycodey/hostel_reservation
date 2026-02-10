import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomSelectionScreen extends StatefulWidget {
  final String hostelId;

  const RoomSelectionScreen({super.key, required this.hostelId});

  @override
  State<RoomSelectionScreen> createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  String? _selectedRoomTypeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Room')),
      body: Column(
        children: [
          // Room Type Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('room_types')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (!snapshot.hasData) return const LinearProgressIndicator();

                final types = snapshot.data!.docs;
                if (types.isEmpty) return const Text('No room types found');

                return DropdownButtonFormField<String>(
                  initialValue: _selectedRoomTypeId,
                  decoration: const InputDecoration(
                    labelText: 'Select Room Type',
                    border: OutlineInputBorder(),
                  ),
                  items: types.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text('${data['name']} (₦${data['price']})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRoomTypeId = value;
                    });
                  },
                );
              },
            ),
          ),

          // Room List based on selection
          Expanded(
            child: _selectedRoomTypeId == null
                ? const Center(child: Text('Please select a room type'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('rooms')
                        .where('hostelId', isEqualTo: widget.hostelId)
                        .where('roomTypeId', isEqualTo: _selectedRoomTypeId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final rooms = snapshot.data!.docs;

                      if (rooms.isEmpty) {
                        return const Center(
                          child: Text('No rooms found for this type.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          final data = room.data() as Map<String, dynamic>;
                          final isAvailable = data['isAvailable'] ?? false;

                          return Card(
                            color: Colors.green,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(
                                data['name'] ?? 'Room',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                isAvailable ? 'Available' : 'Occupied',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: Icon(
                                isAvailable
                                    ? Icons.check_circle_outline
                                    : Icons.block,
                                color: isAvailable
                                    ? Colors.white
                                    : Colors.red[100],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
