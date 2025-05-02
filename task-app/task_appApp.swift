//
//  task_appApp.swift
//  task-app
//
//  Created by Yasira Banuka on 2025-04-21.
//

import SwiftUI
import UserNotifications

@main
struct task_appApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject private var pomodoroTimer = PomodoroTimer()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(pomodoroTimer)
        }
        .modelContainer(for: Task.self)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Request Notification Permission
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied: \(String(describing: error))")
            }
        }
        
        return true
    }
    
    // This method will be called when a notification is delivered to a foreground app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification even when the app is in foreground
        completionHandler([.banner, .sound])
    }
}
