import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/di/injection_container.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'feature/auth/data/datasources/auth_remote_data_source.dart';
import 'feature/auth/data/repositories/auth_repository_impl.dart';
import 'feature/auth/domain/repositories/auth_repository.dart';
import 'feature/auth/domain/usecases/get_current_user.dart';
import 'feature/auth/domain/usecases/sign_in_with_email.dart';
import 'feature/auth/domain/usecases/sign_in_with_google.dart';
import 'feature/auth/domain/usecases/sign_out.dart';
import 'feature/auth/domain/usecases/sign_up_with_email.dart';
import 'feature/auth/presentation/bloc/auth_bloc.dart';
import 'feature/notifications/data/repository/notification_repository_impl.dart';
import 'feature/notifications/data/services/fcm_service.dart' show FcmService;
import 'feature/notifications/data/services/notification_handler.dart';
import 'feature/notifications/domain/repository/notification_repository.dart';
import 'feature/notifications/presentation/bloc/notification_bloc/notification_bloc.dart';
import 'feature/tremor/data/repositories/tremor_repository_impl.dart';
import 'feature/tremor/data/services/tremor_detection_service.dart';
import 'feature/tremor/domain/repositories/tremor_repository.dart';
import 'feature/tremor/presentation/bloc/tremor_bloc.dart';
import 'feature/reminders/data/repositories/reminder_repository_impl.dart';
import 'feature/reminders/domain/repositories/reminder_repository.dart';
import 'feature/reminders/presentation/bloc/reminder_bloc.dart';
import 'core/utils/dummy_data_generator.dart';

void setupFirebaseDependencies() {
  // Firebase instances
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // Data sources
  final authRemoteDataSource = AuthRemoteDataSourceImpl(
    firebaseAuth: firebaseAuth,
    firestore: firestore,
  );

  // Repositories
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );

  // Use cases
  final signInWithEmailUseCase = SignInWithEmailUseCase(authRepository);
  final signUpWithEmailUseCase = SignUpWithEmailUseCase(authRepository);
  final signInWithGoogleUseCase = SignInWithGoogle(authRepository);
  final signOutUseCase = SignOutUseCase(authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);

  // Register with GetIt
  getIt.registerLazySingleton<AuthRepository>(() => authRepository);
  getIt.registerLazySingleton(() => signInWithEmailUseCase);
  getIt.registerLazySingleton(() => signUpWithEmailUseCase);
  getIt.registerLazySingleton(() => signInWithGoogleUseCase);
  getIt.registerLazySingleton(() => signOutUseCase);
  getIt.registerLazySingleton(() => getCurrentUserUseCase);

  // BLoC
  getIt.registerFactory(
    () => AuthBloc(
      signInWithEmailUseCase: getIt(),
      signUpWithEmailUseCase: getIt(),
      signInWithGoogleUseCase: getIt(),
      signOutUseCase: getIt(),
      getCurrentUserUseCase: getIt(),
      authRepository: getIt(),
    ),
  );

  // Theme BLoC
  getIt.registerFactory(() => ThemeBloc());

  // Notification dependencies
  final firebaseMessaging = FirebaseMessaging.instance;
  final flutterLocalNotifications = FlutterLocalNotificationsPlugin();

  final fcmService = FcmService(firebaseMessaging, flutterLocalNotifications);

  final notificationRepository = NotificationRepositoryImpl(
    firestore,
    firebaseAuth,
    fcmService,
  );

  final notificationHandler = NotificationHandler(firestore, firebaseAuth);

  getIt.registerLazySingleton(() => firebaseMessaging);
  getIt.registerLazySingleton(() => flutterLocalNotifications);
  getIt.registerLazySingleton(() => fcmService);
  getIt.registerLazySingleton<NotificationRepository>(
    () => notificationRepository,
  );
  getIt.registerLazySingleton(() => notificationHandler);
  getIt.registerFactory(() => NotificationBloc(getIt()));

  // Tremor dependencies
  final tremorRepository = TremorRepositoryImpl(
    firestore: firestore,
    auth: firebaseAuth,
  );
  final tremorDetectionService = TremorDetectionService();

  getIt.registerLazySingleton<TremorRepository>(() => tremorRepository);
  getIt.registerLazySingleton(() => tremorDetectionService);
  getIt.registerFactory(
    () => TremorBloc(repository: getIt(), detectionService: getIt()),
  );

  // Reminder dependencies
  final reminderRepository = ReminderRepositoryImpl(
    firestore: firestore,
    auth: firebaseAuth,
  );

  getIt.registerLazySingleton<ReminderRepository>(() => reminderRepository);
  getIt.registerFactory(() => ReminderBloc(repository: getIt()));

  // Dummy Data Generator (for testing)
  final dummyDataGenerator = DummyDataGenerator(
    firestore: firestore,
    auth: firebaseAuth,
  );
  getIt.registerLazySingleton(() => dummyDataGenerator);
}
