# SwiftUI Architecture for iOS Applications

This is a simple Fediverse client that provides an example of an architecture that fits naturally with SwiftUI‘s data binding mechanisms. At the time of this writing, it is only confirmed to support authenticating with a Mastodon server.

<details>
<summary><b>Local Setup</b></summary>
<p>
Create a new file at `Diver/Values.swift`:

```swift
import Foundation

let instanceURL = URL(string: "<mastodon-instance-url>")!
```
</p>
</details>

## Layered Architecture

The best fit for an iOS application written in SwiftUI is a layered architecture like MVC or MVVM. Views, like view controllers in UIKit, can become dumping grounds for code. This leads to problems like fragmented application state. A layered architecture with proper separation of concerns helps eliminate these problems. SwiftUI imposes some requirements on how we design such an architecture. Whether MVC, MVVM, or some other pattern, the bridge between model and view in your layered architecture must serve as the _source of truth_ for your user interface.

## Source of Truth

Apple’s documentation emphasizes the importance of this concept. The source of truth for a view is a dynamic value to which the view is bound. When the value changes, the view reloads to present the new state. In a very simple feature, this might just be a property of a view marked with the `@State` annotation. In a non-trivial context, the source of truth is typically a separate observable class with multiple published properties, often provided to the view via dependency injection.

The responsibilities of such a type are as follows:

- Interact with the data layer
- Publish changes to be reflected in the view

Your source of truth might be a controller, a view model, etc. This document avoids these terms and instead refers to the bridge between models and views as the “observable“ layer.

## Model-View-Observable

The layers of our architecture are familiar to anyone with experience in MVC or MVVM. I am not proposing “Model-View-Observable“ as its own architecture pattern but rather as a generalized description of how MVC, MVVM, and related patterns fit into a SwiftUI project.

### Models

Naturally, we need to represent data as entities (models) within the application‘s domain. Entities should conform to the `Identifiable` and `Hashable` protocols to allow SwiftUI to use them in `List`, `ForEach`, etc. Prefer value types for entities as this simplifies `Hashable` and `Equatable` conformance. Entities are often also `Codable`. Entities should provide methods or initializers that support transforming to and from other types such as JSON or DTOs. An entity may contain business logic but if the logic is complex or needs to be mocked, consider using a repository to perform this work. 

#### Repositories

This project leverages the Repository pattern. Repositories are classes in the model layer that provide access to data stores. They typically provide methods to Create, Read, Update, and Delete data. Repositories are responsible for transforming fetched data to instances of your application‘s entities. See PostRepository for an example.

Each repository should define a protocol by which it is accessed. This allows us to create observable types with mock data. This is useful for unit testing, UI testing, and populating Xcode previews. 

### Views

The View is the atomic unit of a SwiftUI application. These are value types conforming to the `View` protocol. They are composable elements that define layout and bind to application data. They are responsible for presenting application state and receiving user interaction. Aim to keep them concise. Views should declare layout and bind to a source of truth. The source of truth for any complex view should be an external observable type. For simple views, the source of truth might be just a binding to a value type. Avoid hooking into lifecycle events, manually tracking value changes, or adding instance methods. If a value change is related to business logic, the change should occur outside the view layer. The view should observe this value through data binding and automatically update to reflect this change. While there is no technical restriction on the code a view may include, we should abide by the axiom that views should not contain business logic. If we have such logic in our view, we want to refactor it into a source of truth.

#### Simple vs. Complex Views

Simple views are small, focused components. Often, these are custom controls or layouts that bind to a single value and are meant for composition within a larger, more complex view. “Complex“ refers to a view that composes other views and often binds to more than a single dynamic value. A view that represents a full screen of content would qualify.

### Observables

Observables are the bridge between model and view layers. For complex views, observables are the source of truth. You might conceptualize these as Controllers, View Models, Stores, or some other abstraction. Observables should be decoupled from views and available to share between views. They may have a to-one relationship with a model type or may represent a bounded context that accesses various model types. They may be orchestrated to enforce consistent state TODO: More on orchestration.

This example project refers to the types in this layer simply as "observables". They are found in Diver/Observables and named for the segment of application state they represent (Navigator.swift, Posts.swift, etc.). For your application, you might take a similar approach or choose the abstraction that best suits your need. Whether controllers, view models, or otherwise, observables should follow a few rules:

1. Annotate @Observable
    
    This macro synthesizes conformance to the `Observable` protocol, causing the class to emit notifications when its properties are modified. This is required so views can respond to data changes.
    
2. Annotate @MainActor

    This property wrapper ensures that updates to the class‘s properties are published on the main actor, where view updates must occur.

3. Mark final

    Not a requirement but a recommendation. Other classes should not inherit from Observables. Use protocol conformance if you need to share functionality across observables.

4. Synchronous methods returning void

    To keep the call site tidy, the methods of an observable should not be asynchronous, throw errors, or return values. Asynchronous operations within these methods should be wrapped in [tasks](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/#Tasks-and-Task-Groups). The return values of these operations, or any errors they raise, should be assigned to published properties of the observable.
    
#### Subscribing to changes

In Rx, Combine, and other reactive paradigms, value updates are typically received through a `subscribe` or `sink` operator. The Observation framework provides no such operator. Change tracking is achieved by the `withObservationTracking(apply:onChange:)` function. Importantly, this only receives the _next_ change to the values accessed in the apply block. For continuous tracking, define a function that invokes `withObservationTracking`. In the `onChange` closure, call the function again to re-subscribe for the next change. See examples in Posts.swift, and Session.swift.  

--- 

Importantly, observables in a SwiftUI context should have no knowledge of the view layer whatsoever. The bridge between observable and view is provided opaquely by the Observation framework. An observable should receive actions forwarded from the view, access the model layer (via a repository in this example), perform any necessary transformations, and update its published properties. The observable is completely decoupled from the view.

> Note on iOS 16 support:
> 
> The [Observation framework](https://developer.apple.com/documentation/Observation) requires a minimum deployment target of iOS 17 or higher. If your application targets iOS 16, observables should conform to the `ObservableObject` protocol. Properties to which views must bind should be annotated `@Published`. When binding views to these properties, the `@Bindable` annotation is not required. `@Published` automatically provides a binding that can be accessed by prefixing the property with `$`.

## Validation

### Previews

For simple views, previews are trivial to configure. For complex views, provide an observable for the source of truth. This observable should be set up to supply mock data. In FeedView, for example, we do this by initializing a `Posts` object with a `MockPostsRepository`. For some views, the source of truth is supplied as an initialization argument. For others, the source of truth is injected into the environment. In this example application, we use the environment for both the FeedView and the PostDetailView.

For many developers, previews are unstable. They often fail to load for complex views. When they do fail, the error messaging is not always helpful. If you encounter a failure, make sure that you have supplied all required dependencies for the view. If that doesn‘t fix it, try splitting your complex view into smaller components. 

### Unit Tests

The observable layer of your application should be well-tested. Use `withObservationTracking` and XCTestExpectation to test asynchronous updates to published properties. In `DiverTests.swift`, I define a convenience method for awaiting a change to a property of the subject under test.

Testing the observable layer is likely to incidentally verify some attributes of your models but it‘s usually worth it to write dedicated tests for the model layer also. Tests for entities are likely to just instantiate a value and verify its properties. Tests for repositories require a mock data source. // TODO: DO THIS?

### UI Tests

Configure the observable layer to use mock repositories when running UI tests. These mocks could be the same you use for previews or you might want separate, dedicated mocks for UI tests. Pass a flag in XCUIApplication‘s launch arguments and, in your application code, provide mock repositories to your observables if the flag is true. See DiverUITests.swift and DiverApp.swift for a minimal example. 

## Common Tasks

### Accessibility

Developing accessible applications is a broad topic but we need not be experts to start making a meaningful impact.

For the essentials, review Apple‘s SwiftUI Accessibility Fundamentals: 
https://developer.apple.com/documentation/swiftui/accessibility-fundamentals

For deeper insight on various mobile accessibility topics, see Rob Whitaker‘s site:
https://mobilea11y.com

The best approach is to rely on Apple‘s framework to provide good default behaviors. Then, carefully audit each view for any issues that need to be addressed. Use Accessibility Inspector to identify issues (Xcode → Open Developer Tool → Accessibility Inspector). This tool can be used to read your UI as VoiceOver would, to inspect an element‘s accessibility attributes, to detect text that will truncate badly at larger sizes, to identify content with insufficient color contrast, and to modify the behavior of your application to reflect common accessibility settings. Remember to localize accessibility labels if your app supports more than one language.

### Navigation

This example project centralizes navigation in a Navigator type. The application has tab-based navigation and each tab hosts a navigation stack. `NavigationStack` and `NavigationPath` are the key components in SwiftUI navigation. The path is bound to the stack. It updates automatically in response to interactions and also allows direct modification of navigation state from code. The NavigationStack must be created in the view layer but the Navigator provides a globally available type (via injection in the Environment) that can create content for navigation destinations and append values to the app‘s navigation path to prompt navigation programmatically.

#### Push / Pop

Navigator defines a Destination subtype, an enumeration of all views in the application that are reachable by a standard push transition. Navigator‘s `go(to destination:)` method appends a `Destination` to the app‘s navigation path and the `content(for destination:)` method provides the target view for the transition. See `FeedView.swift` or `PostDetailView.swift` for usage. 

#### Modals

This project demonstrates a strategy for centralizing modal presentations. Not all applications need such an approach. Many modal presentations are specific to the context of their presenting view. For such cases, simply use the sheet modifier in the presenting view. There are many examples of how to do this. The centralized strategy is useful if you have modals that could be presented from different contexts. 

#### Deep Links

Since Navigator centralizes navigation handling, it is the best place to handle deep links. SwiftUI provides the `onOpenURL` modifier. Attach this modifier to the root view of the application and pass the received value to the Navigator‘s `deepLink` method. See `DiverApp.swift` and `Navigator.swift` for an example.

In the Diver Target‘s Info pane, review the example of the custom URL scheme required for deep link support.

### Push Notifications

This project provides an example of creating an AppDelegate for an application with the SwiftUI lifecycle. The `DiverApp` is the app‘s entry point and cannot conform to UIApplicationDelegate. If an app delegate is needed (e.g., for app lifecycle callbacks or push notification handling) you must create a custom type and provide it to your SwiftUI app via the @UIApplicationDelegateAdaptor property wrapper. See `AppDelegate.swift` and `DiverApp.swift` for an example.

To test push notifications, use the `send-push.sh` script in the `push` folder. There are some example push payloads there. For example:

    cd push && ./send-push.sh deep-link-push.apns
    
### Localization

Disclaimer: I do not speak Spanish. My translations are probably not quite right.

This project uses a [String Catalog](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog) for localization. Follow the instructions in Apple‘s documentation to set up a new catalog. Once the catalog is created, building the project populates the default language with any static text found in code.

Add a new language to the catalog. The catalog entry for the new language is automatically populated with rows for your localizable strings. Manually enter values for each row. The string catalog uses the static text it detected as the keys for localizable strings. Your code does not need to change. Modify the language in your scheme‘s run options and run the application to validate translations.
