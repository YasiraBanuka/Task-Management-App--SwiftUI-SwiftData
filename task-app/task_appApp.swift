//
//  task_appApp.swift
//  task-app
//
//  Created by Yasira Banuka on 2025-04-21.
//

import SwiftUI

@main
struct task_appApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Task.self)
    }
}
