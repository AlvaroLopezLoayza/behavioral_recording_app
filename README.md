# Senda: Systematic Behavioral Recording

**Senda** (formerly Behavioral Recording App) is a premium, evidence-based Flutter application designed for clinical professionals to perform systematic behavioral recording and functional analysis. 

Built with a "Senda" (Path) aesthetic—a blend of corporate professionalism and organic "boho" warmth—this app simplifies complex data collection into a fluid, intuitive experience.

---

## 🌟 Key Features

### 📊 Clinical Data Collection
- **ABC Recording**: Capture Antecedents, Behaviors, and Consequences with structured precision.
- **Operational Definitions**: Enforce measurable and observable behavior standards to eliminate ambiguity.
- **Dynamic Recording Types**: Support for Event (frequency), Duration, Latency, and Interval recording.
- **Clinical Context**: Track Environmental variables (setting, presence of others, emotional state) to enrich analysis.

### 📈 Advanced Analysis
- **Longitudinal Trends**: Visualize behavior frequency over time with integrated phase change lines for intervention mapping.
- **Conditional Probabilities**: Automated analysis of antecedents and consequences to identify functional patterns.
- **Hypothesis Management**: Create and track functional hypotheses tied directly to collected data.
- **Reliability (IOA)**: Integrated Inter-Observer Agreement (IOA) system to ensure data integrity across observers.

### 🛡️ Professional & Secure
- **Supabase Integration**: Real-time synchronization with enterprise-grade security and RLS (Row Level Security).
- **Premium UI/UX**: Custom "Senda" theme featuring Hero animations, fluid transitions, and a curated terracotta/sage/deep-blue palette.
- **Multi-platform**: Optimized for mobile and desktop environments.

---

## 🏗️ Architecture

The codebase adheres to **Clean Architecture** and SOLID principles to ensure long-term maintainability:

- **Domain Layer**: Pure business logic containing Entities, Use Cases, and Repository Interfaces.
- **Data Layer**: Implementation of repositories, remote data sources (Supabase), and DTO (Models).
- **Presentation Layer**: BLoC pattern for state management, reactive widgets, and an atomic design system.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.7.2)
- [Supabase Account](https://supabase.com/)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/AlvaroLopezLoayza/behavioral_recording_app.git
   cd behavioral_recording_app
   ```

2. **Setup Environment**:
   Create a `.env` file in the root directory:
   ```env
   SUPABASE_URL=your_project_url
   SUPABASE_ANON_KEY=your_anon_key
   ```

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run Project**:
   ```bash
   flutter run
   ```

---

## 🛠️ Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: flutter_bloc & bloc
- **Backend/DB**: Supabase (PostgreSQL + Auth + RLS)
- **DI**: get_it
- **Functional**: dartz (Either/Result pattern)
- **UI & Charts**: Google Fonts (Playfair/Lato), fl_chart

---

## 📄 License
This project is private and intended for professional clinical use. All rights reserved.
