# Architecture Decision Record (ADR)

This document captures key architectural decisions and the reasoning behind them.

---

## ADR-001: Application Architecture

**Status:** Accepted  
**Date:** 2026-01-XX

### Decision

Use **MVVM with a Repository pattern**, implemented with:
- SwiftUI
- ViewModels for presentation logic
- A repository coordinating data access
- A service layer for API calls
- SwiftData as a local persistence layer

### Rationale

- MVVM fits naturally with SwiftUI
- A repository cleanly separates UI from data sources
- The structure is easy to understand and extend
- Aligns with recent WWDC guidance

### Consequences

- Slightly more structure than a minimal demo
- Clear ownership and testable boundaries

---

## ADR-002: Persistence Strategy

**Status:** Accepted

### Decision

The remote REST API is the **source of truth**.  
SwiftData is used as a **local cache and UI backing store**.

### Rationale

- Fast app startup
- Offline read support
- Seamless SwiftUI integration via `@Query`

### Consequences

- Offline writes are not supported
- Sync logic is intentionally simple

---

## ADR-003: Navigation

**Status:** Accepted

### Decision

Use SwiftUI’s `NavigationStack` for all navigation.

### Rationale

- Type-safe and explicit
- Minimal boilerplate
- Appropriate for the current scope

---

## ADR-004: Synchronisation Strategy

**Status:** Accepted

### Decision

Use a simple synchronisation approach:
- Remote data replaces or updates local records by ID
- Local state is updated only after successful API calls

### Rationale

- Predictable behaviour
- Easy to reason about and test
- Avoids premature complexity

### Trade-off

This favours simplicity over correctness for complex offline or conflict scenarios.

---

## ADR-005: Reminder System

**Status:** Accepted

### Decision

Implement reminders using `UNUserNotificationCenter`.

- Notifications are scheduled based on medication frequency
- “As needed” medications do not schedule automatic reminders

### Considerations

- Notification permissions
- Time zone changes
- Rescheduling on app launch
