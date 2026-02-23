# Reviews & Complaints — Feature Guide

This document explains the code paths, UI behavior, data flow and storage for the Reviews and Complain/Feedback sections of the app.

## Purpose
- Let users submit reviews tied to past bookings.
- Let users submit complaints/feedback tied to bookings, preserving hostel+room context.
- Provide local-first UX for user-submitted reviews and complaints so items appear immediately (and can be shown offline).

## Files and Responsibilities

- [lib/screens/user_profile.dart](lib/screens/user_profile.dart)
  - Hosts the menu entries for **Reviews** and **Complain / Feedback**.
  - `_showReviewsBottomSheet()` enumerates user bookings (Firestore `bookings` where `userId` equals current user), sorts results client-side by `createdAt`, and displays them in a non-dismissible modal bottom sheet.
  - Tapping a booking closes the sheet and navigates to `ReviewSelectionScreen` after the sheet is dismissed (uses `Future.microtask` to defer navigation).

- [lib/screens/review_selection_screen.dart](lib/screens/review_selection_screen.dart)
  - UI for selecting a star rating and entering an optional textual review for a specific booking.
  - Inputs: `docId` (booking id) and `bookingData` map.
  - On submit: writes review to Firestore and also saves a local JSON copy in SharedPreferences under the key `review_<bookingId>`.

- [lib/screens/view_reviews_page.dart](lib/screens/view_reviews_page.dart)
  - Local-first viewer for past reviews.
  - Loads the locally-saved review from SharedPreferences (key `review_<bookingId>`), merges it with a small set of dummy reviews for display, and renders the combined list.
  - Implemented as a `StatefulWidget` that reads SharedPreferences in `initState`.

- [lib/screens/complaint_feedback_screen.dart](lib/screens/complaint_feedback_screen.dart)
  - Complain / Feedback screen that requires selecting a booking before submitting.
  - Shows a booking selector (streamed `bookings` for the user). Each selector entry displays `roomName — hostelName`.
  - If a booking record lacks `hostelName`, the screen performs a one-time read of the corresponding `hostels` document to resolve the name for display and for saving with the complaint.
  - On submit: complaint payload includes `bookingId`, `hostelId`, `hostelName`, `roomName` and is saved to Firestore and also appended to a local `complaints` JSON array in SharedPreferences.
  - The complaints list UI (_ComplaintCard_) reads the local complaint entries and displays hostel + room alongside message/timestamp.

- [lib/screens/complaint_page.dart](lib/screens/complaint_page.dart) *(if present)*
  - In some flows, review submission logic was also centralized here; when present it follows the same pattern: write to Firestore and save a local copy for immediate visibility.

## Local Persistence (SharedPreferences)
- Review key pattern: `review_<bookingId>` — stores a JSON object representing the user's review for that booking.
- Complaints key: `complaints` — a JSON array of complaint objects; each object includes booking metadata: `bookingId`, `hostelId`, `hostelName`, `roomName`, `message`, `createdAt`.
- Rationale: using local storage makes the app responsive (user sees their review/complaint immediately) and avoids streaming all reviews/complaints via Firestore (which triggered index issues previously).

## Firestore Interactions and Indexing Considerations
- Where queries previously combined `.where(...)` and `.orderBy(...)` that required composite indexes, these server-side `orderBy` calls were removed.
- The app now fetches matching documents (e.g., `bookings.where('userId', isEqualTo: userId)`) and performs client-side sorting by `createdAt` (descending) before rendering.
- This avoids the need to create composite Firestore indexes while preserving correct ordering in the UI.

## Navigation & UX Details
- Reviews bottom sheet: `isDismissible: false` and `enableDrag: false` to prevent accidental dismissal while data is loading.
- Navigation from the sheet captures the sheet's context (the sheet builder `ctx`) and the parent list item `context` is used as `rootCtx` for navigation after popping the sheet. Navigation is deferred with `Future.microtask` to avoid pushing a route while the sheet is still being dismissed.

## Typical Flows

1. Submit a Review
   - User taps **Reviews** in `user_profile.dart` -> bottom sheet lists bookings.
   - Taps a booking -> bottom sheet closes -> `ReviewSelectionScreen` opens with `docId` + `bookingData`.
   - In `ReviewSelectionScreen`, the user rates and optionally writes a message -> taps Submit.
   - App writes the review to Firestore and saves a local JSON under `review_<bookingId>` so `View Past Reviews` can display it immediately.

2. View Past Reviews
   - `ViewReviewsPage` loads local review (if present) from `review_<bookingId>` and shows it along with dummy reviews.
   - No Firestore streaming required for the local-first display.

3. Submit a Complaint / Feedback
   - User taps **Complain / Feedback** in `user_profile.dart` -> navigates to `ComplaintFeedbackScreen`.
   - User selects a booking from the booking selector. The selector label resolves `roomName — hostelName` (may fetch `hostels/<hostelId>` once to get the hostel name if not present).
   - User enters a message and submits. App writes the complaint to Firestore and also appends a local object to the `complaints` SharedPreferences array. Complaint cards show hostel and room info drawn from that local record.

## Where to look in the code (quick pointers)
- Booking selection + reviews menu: [lib/screens/user_profile.dart](lib/screens/user_profile.dart)
- Submit review UI + local save: [lib/screens/review_selection_screen.dart](lib/screens/review_selection_screen.dart)
- View past reviews (local-only): [lib/screens/view_reviews_page.dart](lib/screens/view_reviews_page.dart)
- Complaints UI, booking selector, local complaint store: [lib/screens/complaint_feedback_screen.dart](lib/screens/complaint_feedback_screen.dart)

## Testing checklist
- Select a booking from the Reviews bottom sheet and submit a review — verify the new review appears immediately in `View Past Reviews` (local copy).
- Submit a complaint with a booking selected — verify it appears in the local complaints list with correct `hostelName` and `roomName`.
- Test bookings with missing `hostelName` in the booking doc — the complaint and booking dropdown should fetch `hostels/<hostelId>` to resolve the name.
- Verify ordering: booking lists should show newest bookings first (client-side sorted by `createdAt`).

## Suggested next steps / maintenance notes
- Consider adding a small “Close” button to the non-dismissible reviews bottom sheet if you want an explicit affordance to cancel.
- If you decide to stream full review lists from Firestore later, create the necessary composite indexes in the Firebase console and revert to server-side `orderBy` where appropriate.
- Consider centralizing SharedPreferences utilities (read/write helpers) if not already present to avoid duplication.

---
If you want, I can also:
- Add brief inline diagrams showing data flow (booking -> review -> local + Firestore).
- Add sample JSON shapes for `review_<bookingId>` and `complaints` so other devs know the exact keys.
# hostel_reservation

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# SOE-305-PROJECT

This is the public repository for our open-source Flutter development project (course/module SOE-305).


## Project Overview

A cross-platform mobile application built with Flutter and Dart.  
(You can add a short 1–2 sentence description of what the app actually does here, e.g., "A task management app with Firebase backend" or whatever fits your project.)


## Getting Started

Follow these steps to set up the project locally:

1. **Clone the repository**  
   ```bash
   git clone https://github.com/IdikaEliada/hostel_reservation.git
   cd SOE-305-PROJECT


2. **Install Flutter dependencies**
   ```bash
   flutter pub get

   
3. **Verify your Flutter environment**
   ```bash
   flutter doctor #Resolve any issues (especially Android toolchain, connected devices, or licenses).

   
4. **Firebase Setup**
   - *Install Firebase CLI (if not already installed):*
     ```bash
     npm install -g firebase-tools
   - *Log in to Firebase:*
     ```bash
     firebase login
   - *(If not already done) Initialize Firebase in your project:*
     ```bash
     flutterfire configure   # Recommended — uses the official FlutterFire CLI
   OR manually:
   - Add google-services.json to android/app/
   - Add GoogleService-Info.plist to ios/Runner/
   - Enable desired services (Auth, Firestore, Storage, etc.) in Firebase Console


5. **Run the app**
   - On a connected emulator/device:
     ```bash
     flutter run
   - Or use VS Code / Android Studio run/debug buttons


## Project Structure

We follow a clean, maintainable structure (inspired by common Flutter best practices):

```
user/
├── domain/              # Business Logic Layer (Independent)
│   ├── entities/        # Pure business objects
│   ├── repositories/     # Repository interfaces (contracts)
│   └── usecases/         # Business logic use cases
├── data/                 # Data Layer (Depends on domain)
│   ├── models/           # Data models (with JSON serialization)
│   ├── datasources/      # Remote & Local data sources
│   └── repositories/     # Repository implementations
├── presentation/         # Presentation Layer (Depends on domain)
│   └── pages/            # UI pages/screens
└── di/                   # Dependency Injection
    └── user_dependency_injection.dart
```

### **Contributors**


- Ibiam Idika 20231390342
- Ekeadah Victory Uchenna 20231361742
- Ogueke Chienweatu Blaise 
20231394752
- Nwite Maximilian Somto
20231404342
- Okpara Fortune Nkemakolam 
20231396212
- Ojigbulem desire chimenum 20231393852
- Jude - okoro Dennis 
20231374472
- Benjamin Hilkiah Ihechukwu 
20231406882
- Anyanwu Emmanuel chisom 
20231401262
- Eke Onyinyechi Kalu
20231390652
- Uche Ezeanyika Davis 
20231391692
- Inyama Prince Chinedu 20231377992
