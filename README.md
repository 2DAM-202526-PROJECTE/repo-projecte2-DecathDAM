# DecathDAM

DecathDAM is a SaaS sports equipment application built with Flutter and Firebase.

## Project Structure

The project follows a Clean Architecture approach with a Feature-First organization:

- `lib/core`: Shared utilities, constants, and themes.
- `lib/features`: Feature-specific modules (Auth, Catalog, Cart, Profile, Admin). Each feature contains:
    - `data`: Repositories and data sources.
    - `domain`: Entities and business logic (optional but recommended).
    - `presentation`: Widgets and state management.
- `lib/data`: Shared data services (e.g., Firebase services).

## Features

- **Client Module**: Catalog, Smart Search, Cart, Profile, SaaS Subscription (Premium).
- **Admin Module**: Dashboard, Product Management, Order Management.

## Setup

1. **Prerequisites**:
    - Flutter SDK
    - Firebase Account

2. **Installation**:
    ```bash
    flutter pub get
    ```

3. **Running the App**:
    ```bash
    flutter run
    ```

## Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Auth, Firestore, Storage, Functions)
- **State Management**: Provider (or Bloc/Riverpod as decided)

## Authors
- Alex Caballé Arasa
- Pau Codorniu Duran