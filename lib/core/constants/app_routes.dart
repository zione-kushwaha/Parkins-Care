class AppRoutes {
  AppRoutes._();

  // Auth
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';

  // Main
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Medication
  static const String medications = '/medications';
  static const String addMedication = '/medications/add';
  static const String editMedication = '/medications/edit';
  static const String medicationDetails = '/medications/details';
  static const String medicationHistory = '/medications/history';

  // Symptoms
  static const String symptoms = '/symptoms';
  static const String addSymptom = '/symptoms/add';
  static const String symptomHistory = '/symptoms/history';

  // Exercise
  static const String exercise = '/exercise';
  static const String exerciseDetails = '/exercise/details';
  static const String poseDetection = '/exercise/pose-detection';

  // Yoga
  static const String yoga = '/yoga';
  static const String exerciseHistory = '/exercise/history';

  // Vitals
  static const String vitals = '/vitals';
  static const String addVitals = '/vitals/add';
  static const String vitalsHistory = '/vitals/history';

  // Documents
  static const String documents = '/documents';
  static const String addDocument = '/documents/add';
  static const String documentViewer = '/documents/viewer';

  // Appointments
  static const String appointments = '/appointments';
  static const String addAppointment = '/appointments/add';
  static const String editAppointment = '/appointments/edit';

  // Emergency
  static const String emergency = '/emergency';
  static const String emergencyContacts = '/emergency/contacts';
  static const String nearbyHospitals = '/nearby-hospitals';

  // Video Call
  static const String videoCall = '/video-call';
  static const String emergencyVideoCall = '/emergency-video-call';

  // Caregiver
  static const String caregiverDashboard = '/caregiver';
  static const String patientDetails = '/caregiver/patient';
  static const String patientLocation = '/caregiver/location';

  // Profile
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String editProfile = '/profile/edit';
}
