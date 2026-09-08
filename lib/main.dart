import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobnoti/core/constants/app_theme.dart';
import 'package:jobnoti/core/constants/app_constants.dart';
import 'package:jobnoti/core/network/supabase_client_wrapper.dart';
import 'package:jobnoti/core/di/injection_container.dart' as di;
import 'package:jobnoti/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_event_state.dart';
import 'package:jobnoti/features/auth/presentation/pages/login_page.dart';
import 'package:jobnoti/core/common/widgets/main_shell.dart';
import 'package:jobnoti/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:jobnoti/features/applications/presentation/bloc/application_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jobnoti/firebase_options.dart';
import 'package:jobnoti/core/services/notification_service.dart';
import 'package:jobnoti/features/jobs/presentation/pages/job_details_page.dart' as job_details;
import 'dart:developer';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseClientWrapper.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize Dependency Injection

  await di.initDependencies();

  // Initialize Firebase (safely catch if flutterfire configure hasn't been run)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize Notification Service
    final notificationService = di.sl<NotificationService>();
    notificationService.onNotificationClick = (payload) {
      if (payload.containsKey('job_id')) {
        final jobId = payload['job_id'];
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => job_details.JobDetailsPage(jobId: jobId),
          ),
        );
      }
    };
    await notificationService.initialize();
  } catch (e) {
    log('Firebase could not be initialized. Please run `flutterfire configure`. Error: $e');
  }

  runApp(const JobNotiApp());
}

class JobNotiApp extends StatelessWidget {
  const JobNotiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(const CheckAuthRequested()),
        ),
        BlocProvider<JobBloc>(
          create: (_) => di.sl<JobBloc>(),
        ),
        BlocProvider<ApplicationBloc>(
          create: (_) => di.sl<ApplicationBloc>(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'JobNoti',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is Authenticated) {
          return const MainShell();
        }

        return const LoginPage();
      },
    );
  }
}
