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

### Architecture Diagram

![Architecture Diagram](architecture.png)

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
- All changes are persisted via the REST API

### Reminder System (Bonus)

- Local notifications scheduled using platform APIs
- Supported frequencies:
  - Daily
  - Twice daily
  - Weekly
- “As needed” medications do not receive automatic reminders

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

These trade-offs are documented in the ADR.

---

## What I Would Add With More Time

- User-configurable reminder times
- Offline write support with conflict resolution
- Accessibility and localisation
- Improved error handling and recovery
- App Intents / Siri Shortcuts integration

---

## Notes

AI tools were used to assist with implementation and iteration.  
All architectural decisions and final code reflect my own judgement and experience.
