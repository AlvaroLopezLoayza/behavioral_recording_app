# Behavioral Recording App

A Flutter application for systematic behavioral recording based on functional behavioral analysis principles.

## Overview

This application implements evidence-based behavioral recording methods following Clean Architecture patterns with:

- **ABC Recording**: Antecedent-Behavior-Consequence recording system
- **Operational Definitions**: Enforced observable and measurable behavior definitions
- **Multiple Recording Types**: Event, interval, and continuous recording
- **Real-time Sync**: Supabase backend with real-time data synchronization
- **Data Analysis**: Pattern identification and visualization

## Architecture

The application follows Clean Architecture with three distinct layers:

- **Domain Layer**: Pure business logic, entities, and use cases
- **Data Layer**: Repository implementations, data sources (Supabase), models
- **Presentation Layer**: UI, BLoC state management, widgets

## Tech Stack

- **Framework**: Flutter
- **State Management**: BLoC pattern
- **Backend**: Supabase (PostgreSQL + Real-time)
- **Error Handling**: Either/Result pattern (dartz)
- **Dependency Injection**: get_it
- **Charts**: fl_chart

## Getting Started

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Supabase account

### Installation

1. Clone the repository:
```bash
git clone https://github.com/AlvaroLopezLoayza/behavioral_recording_app.git
cd behavioral_recording_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up Supabase (instructions coming soon)

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/                  # Core utilities and base classes
│   ├── error/            # Error handling (failures, exceptions)
│   ├── usecases/         # Base use case interface
│   ├── utils/            # Constants and validators
│   └── network/          # Network connectivity
├── features/             # Feature modules
│   ├── behavior_definition/
│   ├── abc_recording/
│   ├── analysis/
│   └── authentication/
└── main.dart
```

## Contributing

This project follows strict behavioral analysis principles. Please ensure any contributions maintain:

1. Observable and measurable behavior definitions
2. Proper separation of observation from interpretation
3. Systematic data collection methods
4. Clean Architecture patterns

## License

This project is private and not licensed for public use.
