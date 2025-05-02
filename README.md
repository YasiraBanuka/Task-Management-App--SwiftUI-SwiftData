# 📱 Task Management App with Dynamic Indicators

### 01. Brief Description of Project 

This iOS Task Management App is built using **SwiftUI** and **SwiftData**, featuring a clean, intuitive interface with **dynamic visual indicators**. These indicators change color depending on whether a task is overdue, due today, or completed—helping users immediately identify their most important and time-sensitive work. The app includes multiple screens with smooth navigation and leverages modern iOS development practices to ensure reliability and maintainability.
#

### 02. Users of the System

This app is intended for:

- **Students** tracking assignments, project deadlines, and study goals.
- **Working professionals** managing meetings, deliverables, and to-dos.
- **Individuals** organizing personal tasks, routines, and habits.

Whether you're managing academic workloads or daily life errands, this app offers a simple and effective way to stay on top of your tasks.
#

### 03. What is unique about your solution

- 🟢🟡🔴 **Dynamic Task Indicators** — Instantly visualize the urgency of each task based on color-coded indicators:
  - Red: Overdue
  - Yellow: Due Today
  - Green: Completed

- 🔁 **Smart Sorting** — Tasks are automatically ordered to prioritize upcoming or urgent tasks.

- 💾 **SwiftData Integration** — Native Apple framework used for efficient, persistent storage without any external dependencies.

- 🔔 **Notification Ready Architecture** — Built with scalability in mind to integrate future reminders and alerts.

- 📱 **Polished SwiftUI Interface** — Responsive design, smooth navigation, and touch-friendly UI using buttons, pickers, and date selectors.
#

### 04. Functionality of the screens

#### 🏠 Home Screen – Task List  
Displays all tasks stored locally with SwiftData. Each task has a dynamic color indicator and a tappable card to edit or complete the task.

![Screen 1](Resources/ui1.png)  

#### ➕ Add Task Screen  
Allows users to create a new task with the following fields:
- Title
- Description
- Due Date
- (Optional) Priority

On saving, the task appears in the home list.

![Screen 1](Resources/ui2.png)  
#

### 05. Examples of best practices used when writing code

#### (1) Clear Model Structure with Identifiable
```
struct Task: Identifiable {
    var id: UUID = .init()
    var taskTitle: String
    var creationDate: Date = .init()
    var isCompleted: Bool = false
    var tint: Color
}
```
This follows best practices by:
- Conforming to Identifiable protocol for SwiftUI list rendering
- Using UUID for unique identification
- Providing default values where appropriate

#### (2) Extensions for Code Organization
```
Helpers/View+Extensions.swift

extension View {
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
}
```
Using extensions creates reusable modifiers, reducing code duplication and improving readability.

#### (3) Preference Key for Dynamic Layout
```
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
```
Demonstrates using SwiftUI's preference key system for advanced layout communication.

#### (4) Date Extensions for Readable Code
```
extension Date {
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
}
```
Creating readable computed properties and methods improves code clarity.

#### (5) MVVM Architecture Approach
The project separates concerns with:
- Models (Task.swift)
- Views (Home.swift, TaskRowView.swift)
- Helpers for common functionality

#### (6) SwiftData for Persistence
```
@Query private var tasks: [Task]
```
Using SwiftData's ``@Query`` property wrapper for data persistence and retrieval.
#

### 06. UI Components used

The app uses numerous SwiftUI components:

#### (1) Layout Components
- ```VStack```, ```HStack``` for arranging UI elements
- ```ScrollView``` for scrollable content
- ```TabView``` with ```.page``` style for week slider

#### (2) Interactive Elements
- ```Button``` for actions like adding tasks
- ```DatePicker``` for date selection
- Sheet presentation for task creation

#### (3) Data Display
- ```ForEach``` for iterating over collections
- ```Text``` for displaying information
- Custom task rows with completion indicators

#### (4) Visual Enhancement
- Custom color assets (```DarkBlue```, ```TaskColor1-5```)
- Circle and Rectangle shapes
- Overlay and background modifiers
- Custom animations with ```matchedGeometryEffect```
- ```.strikethrough``` for completed tasks

#### (5) Custom Modifiers
- ```hSpacing``` and ```vSpacing``` for layout control
- Shadow effects for depth
#

### 07. Testing carried out

The following unit tests were implemented to ensure the reliability of core functionality in the Task App: 

```
import XCTest
@testable import task_app

final class TaskModelTests: XCTestCase {
    
    func testTaskCreation() {
        // Given
        let title = "Test Task"
        let date = Date()
        let color = Color.red
        
        // When
        let task = Task(taskTitle: title, creationDate: date, tint: color)
        
        // Then
        XCTAssertEqual(task.taskTitle, title)
        XCTAssertEqual(task.creationDate, date)
        XCTAssertEqual(task.tint, color)
        XCTAssertFalse(task.isCompleted)
    }
    
    func testDateExtensions() {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        // Then
        XCTAssertTrue(today.isToday)
        XCTAssertFalse(yesterday.isToday)
        
        // Test date formatting
        XCTAssertEqual(today.format("yyyy"), Calendar.current.component(.year, from: today).description)
    }
    
    func testWeekGeneration() {
        // Given
        let date = Date()
        
        // When
        let week = date.fetchWeek()
        
        // Then
        XCTAssertEqual(week.count, 7, "Week should contain 7 days")
        
        // Test previous week generation
        if let firstDay = week.first?.date {
            let previousWeek = firstDay.createPreviousWeek()
            XCTAssertEqual(previousWeek.count, 7)
        }
    }
}
```

### 08. Documentation 

#### (a) Design Choices
Task Representation
- Tasks have a title, creation date, completion status, and color tint
- Visual indicators show completion status and time relevance

Weekly Calendar View
- Paginated week view for date selection
- Current day highlighted with a blue circle
- Today marked with a cyan indicator for quick reference

Color System
- Task colors provide visual categorization
- Dark blue accent for highlighted elements
- White background for clean, minimal interface

#### (b) Implementation Decisions
Date Management
- Custom Date extensions for common operations
- Week generation with dynamic pagination
- Date comparison for visual indicators (past, current, future tasks)

UI Architecture
- Component-based approach with TaskRowView for list items
- New task creation via modal sheet
- Custom spacing modifiers for consistent layout

Data Persistence
- SwiftData integration for storing and retrieving tasks
- Dynamic queries based on current date selection

#### (c) Challenges
Week Pagination
- Implementing smooth pagination between weeks
- Maintaining proper state during page transitions
- Creating dynamic week generation based on scroll position

Task Visualization
- Designing an intuitive system to indicate task status
- Creating visual hierarchy for past, current, and future tasks
- Implementing smooth animations for status changes

Layout Management
- Designing a responsive layout that works across different device sizes
- Managing spacing and alignment consistently
- Creating custom preference keys to track scroll offsets

### 09. Reflection

One of the biggest challenges I faced during this assignment was learning how to properly manage state and navigation flow in SwiftUI while working with ```@Query```, ```@State```, and ```@Environment``` properties. SwiftUI’s declarative structure required me to adjust how I approached UI updates, especially when building dynamic task indicators and week pagination.

Another challenge was implementing smooth animations and layout responsiveness for multiple screen sizes. This required careful use of ```matchedGeometryEffect```, spacing modifiers, and custom preference keys to track layout offsets.

If I were to approach this assignment differently, I would start by wireframing more detailed UI/UX flows before writing code. Additionally, I would allocate more time to testing animations and accessibility features to improve usability across a wider range of users.

Overall, this project helped me understand not only the core capabilities of SwiftUI and SwiftData but also how to build scalable UI structures, handle persistent state, and create visually intuitive components for real-world use cases.

  

