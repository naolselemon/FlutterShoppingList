# Shopping List App

## Overview
A simple Flutter application for managing a grocery list, integrated with Firebase Realtime Database for persistent storage. Users can add, view, and remove grocery items, with real-time synchronization across devices.

## Features
- **Add Items:** Input grocery items with name, quantity, and category via a form.
- **View List:** Display items with category color indicators and quantities.
- **Remove Items:** Swipe to delete items, synced with Firebase.
- **Real-Time Sync:** Initial load and updates fetched from Firebase.
- **Error Handling:** Displays loading states and error messages for network issues.

## Dependencies
- `flutter`: Core Flutter framework.
- `flutter_dotenv`: Loads environment variables from `.env`.
- `http`: Makes HTTP requests to Firebase.
- Custom packages: `shopping_list/data/categories.dart`, `shopping_list/models/*`, `shopping_list/widgets/new_item.dart`.

## Setup
1. **Install Flutter:** Ensure Flutter is installed (see [Flutter Docs](https://flutter.dev/docs/get-started/install)).
2. **Clone Repository:** `git clone <repository-url>`
3. **Install Dependencies:** Run `flutter pub get` in the project directory.
4. **Configure Firebase:**
   - Create a Firebase Realtime Database project.
   - Set up a `shopping-list` node.
   - Add `FIREBASE_URL` and `SHOPPING_LIST` to a `.env` file:
5. **Run App:** Execute `flutter run` with a connected device or emulator.

## Usage
- Launch the app to view the grocery list.
- Tap the "+" icon to add a new item.
- Swipe left on an item to delete it.

## Notes
- Environment variables should be loaded globally in `main.dart` for optimal performance (update recommended).
- Ensure internet connectivity for Firebase operations.