import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkins_care/core/theme/bloc/theme_state.dart';
import 'package:parkins_care/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:parkins_care/feature/tremor/presentation/bloc/tremor_bloc.dart';
import 'package:parkins_care/firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/constants/app_colors.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'feature/auth/presentation/bloc/auth_event.dart';
import 'feature/notifications/data/services/fcm_service.dart';
import 'feature/notifications/presentation/bloc/notification_bloc/notification_bloc.dart';
import 'router/app_router.dart';
import 'setup_firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();
  setupFirebaseDependencies();
  await getIt<FcmService>().initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ParkinCareApp());
}

class ParkinCareApp extends StatelessWidget {
  const ParkinCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ThemeBloc>()),
        BlocProvider(
          create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider(create: (_) => getIt<NotificationBloc>()),
        BlocProvider(create: (_) => getIt<TremorBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Parkins-Care',
            debugShowCheckedModeBanner: false,
            theme: themeState is ThemeLoaded
                ? themeState.themeData
                : AppTheme.lightTheme,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
