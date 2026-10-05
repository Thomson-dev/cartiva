import 'package:cartiva/features/home_main/home_main.dart';
import 'package:cartiva/features/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nnsovynlfpcpqiimvanl.supabase.co',
    publishableKey: 'sb_publishable_9rZkM3dpEFYNJ7RD-Jygqg_jAIrGGv4',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'GeneralSans',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),

        colorScheme: .fromSeed(seedColor: Colors.white),
      ),
      home: Supabase.instance.client.auth.currentSession == null
          ? const SignIn()
          : const HomeMain(),
    );
  }
}
