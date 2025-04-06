import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/signup_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'views/screens/forgot_password_screen.dart';
import 'views/screens/main_screen.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(
     DevicePreview(
      enabled: true, // Habilite apenas em debug se preferir
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(),
        ),
        // Adicione outros providers conforme necessário.
      ],
     child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: DevicePreview.appBuilder,
        locale: DevicePreview.locale(context),
        title: 'FrameHub',
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
           '/main': (context) {
              final user = ModalRoute.of(context)!.settings.arguments as AppUser;
              return MainScreen(user: user);
          },
        },
      ),
    );
  }
}