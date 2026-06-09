import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/admin_provider.dart';
import 'views/dashboard_view.dart';
import 'views/login_view.dart';
import 'constants/app_colors.dart';

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
            themeMode: ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              cardColor: AppColors.card,
              dividerColor: AppColors.divider,
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                background: AppColors.background,
                surface: AppColors.surface,
                error: AppColors.error,
              ),
              textTheme: GoogleFonts.interTextTheme(
                ThemeData.light().textTheme,
              ).copyWith(
                titleLarge: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                titleMedium: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
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
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text(
                            'Initializing Admin Workspace...',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
