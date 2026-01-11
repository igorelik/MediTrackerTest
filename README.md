# Medication Tracker (iOS)

A small, focused iOS application built as part of the Healthengine Mobile Tech Test.  
The goal of this project is to demonstrate clear architecture, modern iOS practices, and pragmatic engineering decisions.

---

## Requirements

- Xcode 26
- iOS 18 or later
- Swift 6

---

## Setup

1. Clone the repository
2. Open `MedicationTracker.xcodeproj` in Xcode
3. Select an iOS 18+ simulator or device
4. Build and run

The app uses the provided production API endpoint.  
No additional configuration is required.

---

## Architecture

The app follows a **MVVM + Repository** architecture aligned with modern Apple platform guidance.

**Key principles**
- SwiftUI for all UI
- ViewModels contain presentation logic only
- A repository coordinates data access
- The REST API is the source of truth
- SwiftData is used as a local cache and UI backing store


### Data Flow

1. SwiftUI views read data from SwiftData using `@Query`
2. ViewModels trigger actions (refresh, create, update, delete)
3. The repository:
   - Calls the remote API
   - Updates SwiftData after successful API responses
4. SwiftUI automatically updates when SwiftData changes

---

## Features

### Medication Management

- List medications
- Add a medication (name, dosage, frequency)
- Edit a medication
- Delete a medication
- All changes are persisted via the REST API and cached locally

### Reminder System

- Local notifications scheduled using platform APIs
- Supported frequencies:
  - Daily
  - Twice daily
  - Weekly
- “As needed” medications do not receive automatic reminders. However, the single reminder can be configured

---

## Testing Strategy

Testing focuses on the highest-risk and highest-value areas:

- Repository behaviour and API/SwiftData coordination
- SwiftData persistence using an in-memory store
- ViewModel state changes

UI tests were deprioritised given the scope and time constraints.

---

## Known Limitations

- SwiftData is used as a cache only; offline writes are not supported
- No conflict resolution for multi-device edits
- Notification times are fixed
- Error handling is intentionally minimal
- Form validation is very basic
- Configuration (BaseURL & AppKey) is hard-coded in the ConfigurationService. Real appplication would use a different, more secure approach 
- Authentication is very basic. Username is stored in user defaults. Real app would use a KeyChain for sensitive information


These trade-offs are documented in the ADR.

---

## What I Would Add With More Time

- User-configurable reminder times
- Offline write support with conflict resolution
- Accessibility and localisation
- Improved error handling, data validation, and recovery
- App Intents / Siri Shortcuts integration
- More attention on UI/UX, some animation
- Proper iOC implemntation. 
- "Are you sure" prompt on logout
- More unit tests, especially around notifications
- UI Tests
- Notification permissions are request on app startup. Ideally, it should be requested when user enable reminder for a medication. Also, additional UI needs to be provided for the case when permission is denied. E.g. disable reminder toggle, or provide a button that navigates user to the App Settgins screen to enable permissions

---

