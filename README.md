# MovieWeb App (Flutter)
A Flutter-based movie streaming application that interacts with a Java Spring Boot backend. This app handles UI rendering while the backend manages API processing and business logic.

## Technologies
- **Frontend**: Flutter (Dart)
- **Backend**: Java Spring Boot
- **Streaming**: HLS + Video.js
- **Database**: MySQL
- **Cloud Storage**: AWS S3

## Setup Instructions

### 1. Prerequisites
Ensure the following are installed:
- Flutter SDK ([Installation Guide](https://flutter.dev/docs/get-started/install))
- Android Studio / Visual Studio Code (with Flutter & Dart plugins)
- A physical device or emulator for testing

### 2. Clone the Repository
```sh
git clone https://github.com/your-repo/movieweb_flutter.git
cd movieweb_flutter
```

### 3. Install Dependencies
```sh
flutter pub get
```

### 4. Configure API Endpoint
Modify the `lib/config.dart` file to set up the API base URL:
```dart
const String API_BASE_URL = "https://your-backend-url.com/api";
```

### 5. Run the Application
For Android:
```sh
flutter run
```
For iOS:
```sh
flutter run --release
```

## API Integration
This app communicates with a backend that provides authentication, movie listings, and user preferences. Ensure the backend is running before launching the Flutter app.

## Security Notice
- Environment variables and API keys should be stored securely.
- Do not hardcode sensitive information in the source code.

## Contact
For support, reach out via GitHub: [NguyenDucTrung8149](https://github.com/NguyenDucTrung8149)
