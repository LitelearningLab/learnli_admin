import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/admin_provider.dart';
import 'views/dashboard_view.dart';
import 'views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase using current platform options (Default is Web for this app)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const LearnLiAdminApp());
}

class LearnLiAdminApp extends StatelessWidget {
  const LearnLiAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider(),
      child: Consumer<AdminProvider>(
        builder: (context, adminProv, _) {
          return MaterialApp(
            title: 'LearnLi Admin Console',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              primaryColor: const Color(0xFF6366F1),
              scaffoldBackgroundColor: const Color(0xFF090A0F),
              cardColor: const Color(0xFF131520),
              dividerColor: const Color(0xFF1C1E30),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF6366F1),
                secondary: Color(0xFFA855F7),
                background: Color(0xFF090A0F),
                surface: Color(0xFF0E101A),
                error: Color(0xFFEF4444),
              ),
              textTheme: GoogleFonts.interTextTheme(
                ThemeData.dark().textTheme,
              ).copyWith(
                titleLarge: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                titleMedium: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            home: adminProv.isInitializing
                ? const Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF6366F1)),
                          SizedBox(height: 16),
                          Text(
                            'Initializing Admin Workspace...',
                            style: TextStyle(color: Color(0xFF6C7194), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : adminProv.isAuthenticated
                    ? const DashboardView()
                    : const LoginView(),
          );
        },
      ),
    );
  }
}
