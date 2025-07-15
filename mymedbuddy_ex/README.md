# MyMedBuddy - Personal Health & Medication Manager

A comprehensive Flutter mobile application designed to help users manage their daily health routines, medications, appointments, and health logs with personalized features.

## Features

### Implemented Features

1. **User Onboarding**
   - Form-based user profile creation
   - Stores user data using SharedPreferences
   - Skips onboarding on subsequent app launches
   - Personalized preferences (dark mode, notifications, reminders)

2. **Multi-Screen Navigation**
   - Home Dashboard with health tips and quick actions
   - Medication Schedule (placeholder)
   - Health Logs (placeholder)
   - Appointments (placeholder)
   - Profile (placeholder)

3. **State Management**
   - **Provider**: For user state management (login, preferences, onboarding)
   - **Riverpod**: For health logs with advanced filtering, CRUD operations, and derived state
   - **setState**: For form states and temporary UI interactions

4. **Async Programming & API Integration**
   - Real-time health tips from multiple health APIs (Open Disease, Nutritionix, Advice Slip)
   - COVID-19 data and recovery rates from Open Disease API
   - Nutrition and diet recommendations from Nutritionix
   - Loading states with spinners and error handling with fallback tips
   - Mock medication information API (can be enhanced with openFDA API)

5. **UI Design & Layouts**
   - Responsive dashboard with GridView
   - Cards, ListView, Column, Row layouts
   - Modern Material Design 3 theme
   - Custom widgets for reusability

6. **Shared Preferences**
   - User data persistence
   - App preferences storage
   - Onboarding status tracking

## App Flow
1. **First Launch**: User sees onboarding screen with form
2. **Subsequent Launches**: App skips onboarding and goes directly to home screen
3. **Home Screen**: Dashboard with health tips and navigation cards
4. **Navigation**: Users can navigate to different sections using the dashboard cards

## API Integration
The app integrates with multiple real health APIs from [publicapis.dev](https://publicapis.dev/category/health):

- **Open Disease API**: COVID-19 data and health tips (https://disease.sh/)
- **Nutritionix API**: Nutrition and diet recommendations (https://www.nutritionix.com/business/api)
- **Advice Slip API**: General health advice (https://api.adviceslip.com/)
- **openFDA API**: Medication and drug information (https://open.fda.gov/)

The health tip of the day rotates between these sources and includes:
- Real-time COVID-19 recovery rates and health guidelines
- Nutrition and diet recommendations
- General wellness and lifestyle tips
- Medication safety information

## State Management Architecture
- **Provider**: Used for user state (login status, preferences)
- **Riverpod**: Used for health logs with filtering and advanced features
- **setState**: Used for form states and temporary UI state

