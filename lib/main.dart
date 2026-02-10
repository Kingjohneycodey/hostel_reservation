import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/hostel_list_screen.dart';
import 'screens/hostel_detail_screen.dart';
import 'screens/room_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the seeding function immediately when the app starts
  // await seedHostelData();

  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/hostels',
      builder: (context, state) => const HostelListScreen(),
    ),
    GoRoute(
      path: '/hostel/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final data = state.extra as Map<String, dynamic>?;
        return HostelDetailScreen(hostelId: id, hostelData: data);
      },
    ),
    GoRoute(
      path: '/hostel/:id/rooms',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RoomSelectionScreen(hostelId: id);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hostel Reservation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
