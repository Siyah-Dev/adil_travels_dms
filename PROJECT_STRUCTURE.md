# Adil Taxi DMS – Project structure and where to paste code

All paths below are relative to the project root `adil_taxi_dms/`.

## Folder and file layout

```
lib/
├── main.dart                                    # App entry, Firebase init, GetX
├── core/
│   ├── constants/
│   │   ├── app_constants.dart                    # App name, roles, vehicle options, etc.
│   │   └── firebase_constants.dart                # Firestore field names
│   ├── routes/
│   │   └── app_pages.dart                         # GetX routes and page list
│   ├── theme/
│   │   └── app_theme.dart                         # Theme and colors
│   ├── utils/
│   │   └── pdf_utils.dart                         # Weekly bill PDF generation
│   └── services/
│       └── notification_service.dart              # FCM and local notifications
├── domain/
│   ├── entities/
│   │   ├── user_entity.dart
│   │   ├── driver_profile_entity.dart
│   │   ├── daily_entry_entity.dart
│   │   └── weekly_status_entity.dart
│   └── repositories/
│       ├── auth_repository.dart
│       └── driver_repository.dart
├── data/
│   ├── datasources/
│   │   ├── firebase_auth_datasource.dart
│   │   └── firebase_driver_datasource.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── driver_profile_model.dart
│   │   ├── daily_entry_model.dart
│   │   └── weekly_status_model.dart
│   └── repositories/
│       ├── auth_repository_impl.dart
│       └── driver_repository_impl.dart
└── presentation/
    ├── bindings/
    │   ├── auth_binding.dart
    │   ├── driver_binding.dart
    │   └── admin_binding.dart
    ├── controllers/
    │   ├── auth_controller.dart
    │   ├── driver_profile_controller.dart
    │   ├── daily_entry_controller.dart
    │   ├── driver_weekly_summary_controller.dart
    │   ├── admin_driver_list_controller.dart
    │   ├── admin_driver_detail_controller.dart
    │   ├── admin_daily_entries_controller.dart
    │   ├── admin_weekly_status_controller.dart
    │   └── admin_weekly_summary_controller.dart
    ├── widgets/
    │   ├── app_text_field.dart
    │   ├── app_radio_group.dart
    │   └── section_card.dart
    └── screens/
        ├── auth/
        │   ├── role_selection_screen.dart
        │   └── login_screen.dart
        ├── driver/
        │   ├── driver_home_screen.dart
        │   ├── driver_profile_screen.dart
        │   ├── daily_entry_screen.dart
        │   └── weekly_summary_screen.dart
        └── admin/
            ├── admin_home_screen.dart
            ├── driver_list_screen.dart
            ├── driver_detail_screen.dart
            ├── daily_entries_screen.dart
            ├── weekly_status_screen.dart
            └── weekly_summary_report_screen.dart
```

## Firebase setup

1. **Firestore**
   - Create collections: `users`, `drivers`, `daily_entries`, `weekly_status`.
   - **users**: document ID = Firebase Auth UID; fields: `email`, `role` (`admin` or `driver`), `displayName`, `fcmToken`, `isSuspended`, `createdAt`.
   - **drivers**: document ID = same as user UID for that driver; fields: `userId`, `name`, `age`, `address`, `place`, `pincode`, `aadharNumber`, `drivingLicenceNumber`, `updatedAt`.
   - **daily_entries**: auto ID; fields: `driverId`, `driverName`, `date`, `startKm`, `startTime`, `endKm`, `endTime`, `fuelAmount`, `fuelPaidBy`, `vehicleNumber`, `totalEarning`, `cashCollected`, `servicesUsed`, `privateTripCash`, `tollPaidByCustomer`, `createdAt`, `updatedAt`.
   - **weekly_status**: auto ID; fields: `driverId`, `driverName`, `weekStartDate`, `weekEndDate`, `totalEarnings`, `totalCashCollected`, `cashAgainstEarnings`, `commissionFleet`, `phonePayReceived`, `roomRent`, `petrolExpense`, `pendingBalance`, `finalBalance`, `createdAt`, `updatedAt`.

2. **Security rules**
   - Restrict read/write by `role` and `uid` so drivers see only their data and admins see all.

3. **Notifications**
   - Morning/evening reminders for drivers and admins are best implemented with **scheduled Cloud Functions** that:
     - Query daily entries for the day and find drivers with missing mandatory fields.
     - Send FCM to those drivers and to admin FCM tokens (from `users` where `role == 'admin'`).
   - `NotificationService` in the app handles receiving and displaying FCM and stores FCM token in `users` on login.

## Running the app

1. `flutter pub get`
2. Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in place (Firebase console).
3. Run: `flutter run`

First use: create at least one user in Firebase Auth and a matching document in `users` with the same UID and `role: 'admin'` or `role: 'driver'`. For drivers, a document in `drivers` with that UID will be created when they save their profile.
