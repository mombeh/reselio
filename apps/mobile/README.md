# Mobile

Reselio mobile application built with Flutter. Connects to the NestJS backend API for role-based authentication (customer, client, admin) and all business features.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (>= 3.13.0) - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (>= 3.13.0) - Comes with Flutter
- **Node.js** (>= 18.x) and **npm** - [Install Node.js](https://nodejs.org/)
- **MongoDB** - Local installation or MongoDB Atlas account
- **Git**
- **Android Studio** or **VS Code** with Flutter extensions (for mobile emulators)
- **Xcode** (required for iOS development on macOS)

## Project Structure

```
reselio/
├── apps/
│   ├── api/          # NestJS backend API
│   └── mobile/       # Flutter mobile app (this folder)
```

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd reselio
```

### 2. Set Up the Backend API

The mobile app requires the backend API running. Navigate to the API folder and set it up:

```bash
cd apps/api

# Install dependencies
npm install

# Create a .env file in apps/api/ with the following:
# MONGO_URL=mongodb://localhost:27017/reseliodb
# GOOGLE_CLIENT_ID=your_google_client_id
# GOOGLE_CLIENT_SECRET=your_google_client_secret
# FRONTEND_URL=http://localhost:3000

# Start the development server
npm run start:dev
```

The API will be available at `http://localhost:3000` by default.

> **Note:** Ensure MongoDB is running locally or use a MongoDB Atlas connection string in the `.env` file.

### 3. Set Up the Flutter Mobile App

Navigate to the mobile app folder:

```bash
cd apps/mobile
```

#### Install Dependencies

```bash
flutter pub get
```

#### Configure API Base URL

Create a `.env` file or update the API configuration in the app to point to your backend:

For development with an emulator:
- **Android Emulator:** Use `http://10.0.2.2:3000`
- **iOS Simulator:** Use `http://localhost:3000`
- **Physical Device:** Use your machine's local IP address, e.g., `http://192.168.1.100:3000`

#### iOS Setup (macOS only)

```bash
cd ios
pod install
cd ..
```

### 4. Run the App

Connect a device or start an emulator, then:

```bash
# Run in debug mode
flutter run

# Run on a specific device
flutter run -d <device-id>

# Build for release (Android)
flutter build apk --release

# Build for release (iOS)
flutter build ios --release
```

## Authentication

The app supports role-based authentication with the following roles:

- **Customer** - Default role for general users
- **Client** - For business clients
- **Admin** - For administrators

### Register

Send a POST request to `/auth/register` with:

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "role": "customer" // optional, defaults to "customer"
}
```

### Login

Send a POST request to `/auth/login` with:

```json
{
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

The response includes a JWT access token and user data including the role.

### Google Sign-In (Mobile)

Send a POST request to `/auth/google/mobile` with:

```json
{
  "accessToken": "google_oauth_access_token"
}
```

### Get Profile

Send a GET request to `/auth/me` with the Authorization header:

```
Authorization: Bearer <access_token>
```

## Features

- Role-based authentication (Customer, Client, Admin)
- JWT token-based authentication
- Google OAuth sign-in
- User profile management
- Password update functionality

## Troubleshooting

### Gradle Build Issues

Ensure you have the correct Java version (JDK 17) installed:

```bash
java -version
```

### iOS Build Issues

Make sure CocoaPods is installed:

```bash
sudo gem install cocoapods
cd ios && pod install
```

### API Connection Issues

- Verify the API server is running (`npm run start:dev` in `apps/api`)
- Check that the base URL in the Flutter app matches the API address
- Ensure no firewall is blocking the connection

## Development

### Code Analysis

```bash
flutter analyze
```

### Run Tests

```bash
flutter test
```

### Format Code

```bash
flutter format .
```

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **State Management:** (to be configured)
- **Backend:** NestJS (Node.js)
- **Database:** MongoDB
