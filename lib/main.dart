import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hostel_reservation/data_seeder.dart';
import 'firebase_options.dart';
import 'providers/router_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hostel_reservation/registration_screen.dart';
import 'package:hostel_reservation/sign_in_screen.dart';
import 'package:hostel_reservation/splash_screen.dart';
//import 'data_seeder.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/hostel_list_screen.dart';
import 'screens/hostel_detail_screen.dart';
import 'screens/room_selection_screen.dart';
import 'screens/complaint_page.dart';
import 'screens/review_page.dart';
import 'screens/feedback_screen.dart';
import 'screens/admin/manage_rooms_screen.dart';
import 'screens/admin/add_edit_room_screen.dart';
import 'screens/user_profile.dart';
import 'sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the seeding function immediately when the app starts
  // await seedHostelData();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

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
      routerConfig: router,
    );
  }
}
