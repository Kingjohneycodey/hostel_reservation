import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> seedHostelData() async {
  final firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  try {
    print('Seeding database...');

    // 1. Create a Hostel
    final DocumentReference
    hostelRef = await firestore.collection('hostels').add({
      'name': 'Happy Stay Hostel',
      'totalRooms': 5,
      'availableRooms': 5,
      'imageUrls': [
        'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=600&q=80',
      ],
      'imageUrl': // Keep for backward compatibility if needed, or remove if schema is strict.
          'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=600&q=80',
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('Hostel created: ${hostelRef.id}');

    // 2. Ensure Room Types Exist (Reuse if available to avoid duplicates)
    final List<Map<String, dynamic>> roomTypesData = [
      {'name': 'Single Room', 'capacity': 1, 'price': 1000},
      {'name': 'Double Room', 'capacity': 2, 'price': 1500},
      {'name': 'Dormitory Bed', 'capacity': 1, 'price': 500},
    ];
    print('Checking/Creating room types...');
    // ── 3. Seed current user document ──────────────────────────────────────
    if (currentUser != null) {
      await firestore.collection('users').doc(currentUser.uid).set({
        'name': 'Test User',
        'email': currentUser.email ?? 'test@email.com',
        'phone': '08012345678',
        'location': 'Lagos, Nigeria',
        'avatarUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('User document created: ${currentUser.uid}');
    }

    if (currentUser != null) {
      final bookingRef = await firestore.collection('bookings').add({
        'userId': currentUser.uid,
        'hostelId': hostelRef.id,
        //'roomName': bookedRoomName ?? 'Room 101',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Booking created: ${bookingRef.id}');
    }

    List<String> roomTypeIds = [];

    for (var typeData in roomTypesData) {
      final String typeName = typeData['name'];

      // Check if this type already exists
      final existingTypeQuery = await firestore
          .collection('room_types')
          .where('name', isEqualTo: typeName)
          .limit(1)
          .get();

      if (existingTypeQuery.docs.isNotEmpty) {
        print('Using existing room type: $typeName');
        roomTypeIds.add(existingTypeQuery.docs.first.id);
      } else {
        print('Creating new room type: $typeName');
        final typeRef = await firestore.collection('room_types').add({
          ...typeData,
          'createdAt': FieldValue.serverTimestamp(),
        });
        roomTypeIds.add(typeRef.id);
      }
    }
    print('Room type IDs verified: $roomTypeIds');

    // 3. Create Rooms for the Hostel
    // We will assign room types cyclically
    final List<String> roomNames = [
      'Room 101',
      'Room 102',
      'Room 103',
      'Room 104',
      'Room 105',
    ];

    print('Creating rooms...');

    final WriteBatch batch = firestore.batch();

    for (int i = 0; i < roomNames.length; i++) {
      final roomRef = firestore.collection('rooms').doc();
      // Cycle through room types: 0, 1, 2, 0, 1...
      final roomTypeId = roomTypeIds[i % roomTypeIds.length];

      batch.set(roomRef, {
        'hostelId': hostelRef.id,
        'name': roomNames[i],
        'roomTypeId': roomTypeId,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    print('Rooms created successfully!');
  } catch (e) {
    print('Error seeding data: $e');
  }
}
