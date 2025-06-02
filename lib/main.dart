import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/user_service.dart';
import 'splash_screen.dart';
import 'auth_module/login_screen.dart';
import 'auth_module/signup_screen.dart';
import 'auth_module/reset_password_screen.dart';
import 'parent_module/profile_setup_screen.dart';
import 'parent_module/setting_screen.dart';
import 'children_module/module4/module4_screen.dart';
import 'children_module/module5/module5_screen.dart';
import 'children_module/module6/module6_screen.dart';
import 'children_module/module4/module4_playScreen.dart';
import 'children_module/module5/module5_playScreen.dart';
import 'children_module/module6/module6_playScreen.dart';
import 'children_module/Learn/subjectSelection_screen.dart';
import 'children_module/Learn/chapterSelection_screen.dart';
import 'children_module/Learn/learning_selection_screen.dart';
import 'children_module/Learn/note_viewer_screen.dart';
import 'children_module/Game/gameSubjectSelection_screen.dart';
import 'children_module/Game/gameChapterSelection_screen.dart';
import 'children_module/Game/gameSelection_screen.dart';
import 'admin_module/adminhome_screen.dart';
import 'admin_module/user_management/user_list_screen.dart';
import 'admin_module/content_management/content_management_screen.dart';
import 'admin_module/analytic/analytic_screen.dart';
import 'models/subject.dart';
import 'models/note_content.dart';
import 'services/screen_time_wrapper.dart';
import 'services/screen_time_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDkdpsCM91Y28-KJWKad1z879dBaFfohMM",
        authDomain: "little-explorer-2b3a6.firebaseapp.com",
        projectId: "little-explorer-2b3a6",
        storageBucket: "little-explorer-2b3a6.firebasestorage.app",
        messagingSenderId: "402449554249",
        appId: "1:402449554249:web:0695a79fd55b6679b71898",
        measurementId: "G-L6SQVKFDT9",
      ),
    );
  } else {
    await Firebase.initializeApp(); // Uses google-services.json on Android
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // Create a singleton instance of UserService
  static final UserService _userService = UserService();
  
  // Helper method to get real user name
  static Future<String> _getRealUserName(String userId) async {
    return await _userService.getRealUserName(userId);
  }
  
  // Synchronous helper for immediate UI needs
  static String _getRealUserNameSync(String userId) {
    return _userService.getRealUserNameSync(userId);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTimeWrapper(
      enforceScreenTime: true,
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Little Explorers',
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/reset': (context) => const ResetPasswordScreen(),
        '/profile': (context) => const ProfileSetupScreen(),
        '/settings': (context) => const SettingScreen(userId: 'default_user'),
        '/module4': (context) => Module4Screen(userId: 'default_user', userName: _getRealUserNameSync('default_user')),
        '/module5': (context) => Module5Screen(userId: 'default_user', userName: _getRealUserNameSync('default_user')),
        '/module6': (context) => Module6Screen(userId: 'default_user', userName: _getRealUserNameSync('default_user')),
        // '/play' route removed as it's no longer needed
        '/module4Play': (context) => Module4PlayScreen(userId: 'default_user', userName: _getRealUserNameSync('default_user')),
        '/module5Play': (context) => Module5PlayScreen(userId: 'default_user', userName: _getRealUserNameSync('default_user')),
        '/module6Play': (context) => Module6PlayScreen(userId: 'default_user', userName: _getRealUserNameSync('default_user')),
        '/subjectSelection': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          int moduleId = 4;
          String userId = 'default_user';
          
          if (args is Map<String, dynamic>) {
            moduleId = args['moduleId'] as int? ?? 4;
            userId = args['userId'] as String? ?? 'default_user';
          } else if (args is int) {
            moduleId = args;
          }
          
          // Always get the real user name
          String userName = _getRealUserNameSync(userId);
          
          return SubjectSelectionScreen(
            moduleId: moduleId,
            userId: userId,
            userName: userName,
          );
        },
        '/chapterSelection': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          late Subject subject;
          String userId = 'default_user';
          
          if (args is Map<String, dynamic>) {
            subject = args['subject'] as Subject;
            userId = args['userId'] as String? ?? 'default_user';
          } else if (args is Subject) {
            subject = args;
          } else {
            // Fallback to prevent crashes
            return const Scaffold(
              body: Center(child: Text('Invalid subject data')),
            );
          }
          
          // Always get the real user name
          String userName = _getRealUserNameSync(userId);
          
          return ChapterSelectionScreen(
            subject: subject,
            userId: userId,
            userName: userName,
          );
        },
        '/gameSubjectSelection': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          int moduleId = 4;
          String userId = 'default_user';
          
          if (args is Map<String, dynamic>) {
            moduleId = args['moduleId'] as int? ?? 4;
            userId = args['userId'] as String? ?? 'default_user';
          } else if (args is int) {
            moduleId = args;
          }
          
          // Always get the real user name
          String userName = _getRealUserNameSync(userId);
          
          return GameSubjectSelectionScreen(
            moduleId: moduleId,
            userId: userId,
            userName: userName,
          );
        },
        '/gameChapterSelection': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          late Subject subject;
          String userId = 'default_user';
          
          if (args is Map<String, dynamic>) {
            subject = args['subject'] as Subject;
            userId = args['userId'] as String? ?? 'default_user';
          } else if (args is Subject) {
            subject = args;
          } else {
            // Fallback to prevent crashes
            return const Scaffold(
              body: Center(child: Text('Invalid subject data')),
            );
          }
          
          // Always get the real user name
          String userName = _getRealUserNameSync(userId);
          
          return GameChapterSelectionScreen(
            subject: subject,
            userId: userId,
            userName: userName,
          );
        },
        '/learningSelection': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          final userId = args['userId'] as String? ?? 'default_user';
          
          // Always get the real user name
          final userName = _getRealUserNameSync(userId);
          
          return LearningSelectionScreen(
            chapter: args['chapter'] as Chapter,
            subjectId: args['subjectId'] as String,
            userId: userId,
            userName: userName,
          );
        },
        '/noteViewer': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          final userId = args['userId'] as String? ?? 'default_user';
          
          // Always get the real user name
          final userName = _getRealUserNameSync(userId);
          
          return NoteViewerScreen(
            note: args['note'] as Note,
            chapterName: args['chapterName'] as String,
            userId: userId,
            userName: userName,
            subjectId: args['subjectId'] as String,
            subjectName: args['subjectName'] as String? ?? args['chapterName'] as String,
            chapterId: args['chapterId'] as String,
            ageGroup: args['ageGroup'] as int? ?? 4,
          );
        },
        '/adminHome': (context) => const AdminHomeScreen(),
        '/userManagement': (context) => const UserListScreen(),
        '/contentManagement': (context) => const ContentManagementScreen(),
        '/analytics': (context) => const AnalyticScreen(),
      },
    ),
    );
  }
}
