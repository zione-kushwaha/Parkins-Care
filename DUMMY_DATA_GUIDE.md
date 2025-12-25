# Dummy Data Management Guide

## Overview
The app now includes comprehensive tools for managing test/sample data for development and testing purposes.

## Features

### 1. Add Dummy Data
- **Location**: Settings → Developer Tools → "Add Dummy Data"
- **Action**: Adds sample data if none exists
- **Includes**:
  - 8 Reminders (medications, appointments, exercises)
  - 7 Notifications (welcome, reminders, progress updates)

### 2. Regenerate Dummy Data
- **Location**: Settings → Developer Tools → "Regenerate Dummy Data"
- **Action**: Clears ALL existing data and creates fresh sample data
- **Use Case**: When you want to reset your test data completely
- **Warning**: Requires confirmation dialog

### 3. Clear All Data
- **Location**: Settings → Developer Tools → "Clear All Data"
- **Action**: Permanently deletes all reminders and notifications
- **Use Case**: Clean slate for testing
- **Warning**: Requires confirmation dialog with red button

## Fixed Issues

### Timestamp Type Error
**Problem**: Notifications were throwing `type 'String' is not a subtype of type 'Timestamp'` error

**Solution**: The `NotificationModel.fromFirestore()` now handles multiple timestamp formats:
```dart
// Handles both Timestamp and String formats
if (timestampData is Timestamp) {
  timestamp = timestampData.toDate();
} else if (timestampData is String) {
  timestamp = DateTime.parse(timestampData);
} else {
  timestamp = DateTime.now();
}
```

### Data Persistence
- All dummy data is stored in Firestore with proper types
- Timestamps are stored as Firestore `Timestamp` objects (not strings)
- Data persists across app restarts

## Sample Data Details

### Reminders (8 total)
1. **Morning Medication** (Daily, 8:00 AM) - Levodopa 100mg
2. **Evening Medication** (Daily, 6:00 PM) - Carbidopa 25mg
3. **Neurologist Appointment** (Tomorrow, 10:30 AM)
4. **Physical Therapy** (2 days, 2:00 PM) - Weekly session
5. **Morning Exercise** (Daily, 7:00 AM) - 30 min stretching
6. **Blood Pressure Check** (Daily, 9:00 AM)
7. **Afternoon Medication** (Daily, 2:00 PM) - Ropinirole 2mg
8. **Weekly Support Group** (Weekly Monday, 6:00 PM)

### Notifications (7 total)
1. **Welcome Message** (2 hours ago)
2. **Medication Reminder Set** (1 hour ago)
3. **Appointment Scheduled** (30 minutes ago)
4. **Exercise Completed** (15 minutes ago) - "Great job!"
5. **Tremor Detection Active** (Yesterday)
6. **Weekly Progress Report** (2 days ago) - "90% completion"
7. **New Feature Available** (3 days ago)

## Developer Notes

### Code Structure
- **DummyDataGenerator**: `lib/core/utils/dummy_data_generator.dart`
- **Methods**:
  - `addDummyReminders({bool force = false})`
  - `addDummyNotifications({bool force = false})`
  - `addAllDummyData({bool force = false})`
  - `clearAllData()`
  - `regenerateAllData()`

### Force Parameter
The `force` parameter allows overriding the "already exists" check:
```dart
// Skip if data exists
await generator.addAllDummyData();

// Force add even if exists (not recommended - duplicates data)
await generator.addAllDummyData(force: true);

// Better approach: clear first, then add
await generator.regenerateAllData();
```

### Integration
All methods are integrated into the Settings page with proper:
- Loading indicators
- Success/error messages
- Confirmation dialogs for destructive actions

## Troubleshooting

### "No user logged in" Error
- Make sure you're logged in before adding dummy data
- Check that Firebase Auth is working properly

### Network Errors
- Ensure device/emulator has internet connectivity
- Verify Firebase project is configured correctly

### Data Not Appearing
1. Try pulling down to refresh in the Reminders/Notifications screens
2. Check Firebase Console → Firestore to verify data exists
3. Look at debug logs for any errors

### Timestamp Errors
If you still see timestamp-related errors:
1. Use "Regenerate Dummy Data" to recreate with correct format
2. Check that you pulled the latest code changes
3. Verify `notification_model.dart` has the flexible timestamp parsing

## Best Practices

1. **Development**: Use "Add Dummy Data" once per user
2. **Testing**: Use "Regenerate Dummy Data" to reset between test runs
3. **Production**: Remove or hide the Developer Tools section
4. **Clean Up**: Use "Clear All Data" before testing fresh user flows

## Future Improvements

Possible enhancements:
- Add more variety in reminder types
- Include completed reminders in sample data
- Add recurring pattern variations
- Generate user-specific data based on profile
- Export/import dummy data configurations
