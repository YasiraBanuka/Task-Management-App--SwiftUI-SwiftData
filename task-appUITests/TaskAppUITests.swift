//
//  TaskAppUITests.swift
//  task-appUITests
//
//  Created by Yasira Banuka on 2025-05-02.
//

import XCTest

class TaskAppUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    
    func testBasicTaskCreation() throws {
        // Verify initial UI elements are present
        XCTAssertTrue(app.staticTexts["No Tasks Found"].exists, "Should show 'No Tasks Found' initially")
        
        // Tap the + button to create a new task
        app.buttons["plus"].tap()
        
        // Enter a task title
        let taskTitleField = app.textFields.firstMatch
        taskTitleField.tap()
        taskTitleField.typeText("Buy groceries")
        
        // Create the task (without selecting a color - it will use the default)
        app.buttons["Create Task"].tap()
        
        // Verify task was created
        XCTAssertTrue(app.staticTexts["Buy groceries"].exists, "Task should be created and visible")
        XCTAssertFalse(app.staticTexts["No Tasks Found"].exists, "No longer should show empty state")
        
        // Mark task as completed
        let taskRow = app.staticTexts["Buy groceries"].firstMatch
        // Tap slightly to the left of the task text to hit the circle button
        let taskRowFrame = taskRow.frame
        let circleLocation = CGPoint(x: taskRowFrame.minX - 15, y: taskRowFrame.midY)
        app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: circleLocation.x, dy: circleLocation.y))
            .tap()
        
        // Clean up - delete the task
        taskRow.press(forDuration: 1.0)
        app.buttons["Delete Task"].tap()
        
        // Verify task was deleted
        XCTAssertTrue(app.staticTexts["No Tasks Found"].exists, "Should show 'No Tasks Found' after deletion")
    }
    
    
    
    
    func testSearchForNonExistentTask() throws {
        // This test will fail because it looks for a non-existent task
        
        // Verify we're on the home screen
        XCTAssertTrue(app.staticTexts["No Tasks Found"].exists, "Should show 'No Tasks Found' initially")
        
        // Attempt to find a task that doesn't exist
        let nonExistentTask = app.staticTexts["This Task Does Not Exist"]
        XCTAssertTrue(nonExistentTask.exists, "Should find a non-existent task (this assertion should fail)")
        
        // Attempt to tap on a non-existent task
        nonExistentTask.tap()
    }
    
    func testIncorrectButtonIdentifiers() throws {
        // This test will fail because it looks for buttons with incorrect identifiers
        
        // Try to tap a button with an incorrect identifier
        app.buttons["add_new_task"].tap() // The actual identifier is likely "plus"
        
        // Wait a moment to see if anything happens
        sleep(1)
        
        // This assertion should fail because the new task view shouldn't appear
        XCTAssertTrue(app.textFields.firstMatch.exists, "New task view should appear")
    }
    
    func testInvalidColorSelection() throws {
        // This test will fail when trying to select a color that doesn't exist
        
        // Tap the + button to create a new task
        app.buttons["plus"].tap()
        
        // Enter a task title
        let taskTitleField = app.textFields.firstMatch
        taskTitleField.tap()
        taskTitleField.typeText("Task With Invalid Color")
        
        // Try to select a non-existent color option (incorrect path to the element)
        app.buttons["TaskColor 10"].tap() // There are only 5 task colors
        
        // Try to create the task
        app.buttons["Create Task"].tap()
        
        // This might still succeed if it ignores the color selection
        // but we're testing for the specific color selection failure
        XCTAssertTrue(app.staticTexts["Invalid Color Selection"].exists, "Should show error message")
    }
    
    func testPomodoroTimerWithoutTask() throws {
        // This test will fail because it tries to interact with the Pomodoro timer view
        // without properly creating and selecting a task first
        
        // Try to directly show the Pomodoro view without creating a task
        app.buttons["Focus"].tap() // This button shouldn't exist without a task
        
        // This should fail because the Pomodoro view shouldn't appear
        XCTAssertTrue(app.staticTexts["Pomodoro Timer"].exists, "Pomodoro view should appear")
    }
}
