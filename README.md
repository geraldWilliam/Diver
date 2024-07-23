# SwiftUI Application Architecture

This project provides an example of a layered architecture that fits naturally with SwiftUI‘s data binding mechanisms.

## Layered Architecture

The best fit for an iOS application written in SwiftUI is a layered architecture like MVC or MVVM. 

### Models

Naturally, we need to model our domain data. Your entities should conform to the `Identifiable` and `Hashable` protocols to allow SwiftUI to use them in `List`, `ForEach`, etc. This project leverages the Repository pattern and considers the repository part of the model layer.

### Views

The View is the atomic unit of a SwiftUI application. These are value types conforming to the `View` protocol. They are responsible for presenting application state and receiving user interaction. Aim to keep them concise. Views should declare layout and bind to a source of truth. The source of truth for any complex view should be an external observable type. For small, composable views the source of truth might be a simple binding to a value type.

#### Simple vs. Complex

Simple views are small, focused components. Often, these are custom controls or layouts that bind to a single value and are meant for composition within a larger, more complex view. “Complex“ refers to a view that composes other views and often binds to more than a single dynamic value. A view that represents a full screen of content would qualify.

### Observables

Observables are the bridge between model and view layers. For complex views, these are the source of truth. You might conceptualize these as Controllers, View Models, Stores, or some other abstraction. Observables should be decoupled from views and available to share between views. They may have a to-one relationship with a model type or may represent a bounded context that accesses various model types. They may be orchestrated to enforce consistent state.

In this example project, we just use the term “Observable“. Choose the abstraction that best suits your need. Whether controllers, view models, or otherwise, observables should follow a few rules:

1. Annotate @Observable
2. Annotate @MainActor
3. Mark final
4. Synchronous methods returning void

Importantly, observables in a SwiftUI context should have no knowledge of the view layer whatsoever. The bridge between observable and view is provided opaquely by the Observation framework. An observable should receive actions forwarded from the view, access the model layer (via a repository in this example), perform any necessary transformations, and update its published properties. The observable is completely decoupled from the view.

## Common Tasks

### Navigation

This example app centralizes navigation in a Navigator type. SwiftUI offers a flexible solution for navigation in `NavigationStack`. The NavigationStack must be created in the view layer but the Navigator provides a globally available type (via injection in the Environment) that can create content for navigation destinations, append values to the app‘s navigation path...

#### Deep Links

Since Navigator centralizes navigation handling, it is the best place to handle deep links. SwiftUI provides the `onOpenURL` modifier. Attach this modifier to the root view of the application and pass the received value to the Navigator‘s `deepLink` method. See `DiverApp.swift` and `Navigator.swift` for an example. 

### Push Notifications

This project provides an example of creating an AppDelegate for an application with the SwiftUI lifecycle. The `DiverApp` is the app‘s entry point and cannot conform to UIApplicationDelegate. If an app delegate is needed (e.g., for app lifecycle callbacks or push notification handling) you must create a custom type and provide it to your SwiftUI app via the @UIApplicationDelegateAdaptor property wrapper. See `AppDelegate.swift` and `DiverApp.swift` for an example.

## Unit Tests

The Observable layer of your application should be well-tested. Use `withObservationTracking` and XCTExpectation 

## UI Tests




