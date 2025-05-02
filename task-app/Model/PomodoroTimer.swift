//
//  PomodoroTimer.swift
//  task-app
//
//  Created by Yasira Banuka on 2025-05-02.
//

import SwiftUI
import Combine

class PomodoroTimer: ObservableObject {
    // Timer settings
    @Published var workDuration: Int = 25 * 60  // 25 minutes in seconds
    @Published var shortBreakDuration: Int = 5 * 60  // 5 minutes
    @Published var longBreakDuration: Int = 15 * 60  // 15 minutes
    @Published var pomodorosUntilLongBreak: Int = 4
    
    // Timer state
    @Published var timeRemaining: Int = 25 * 60
    @Published var isActive: Bool = false
    @Published var isWorkSession: Bool = true
    @Published var completedPomodoros: Int = 0
    @Published var currentTaskId: UUID?
    
    private var timer: AnyCancellable?
    private var startTime: Date?
    
    func startTimer(taskId: UUID) {
        if currentTaskId != taskId {
            // Reset timer for new task
            resetTimer()
            currentTaskId = taskId
        }
        
        if !isActive {
            isActive = true
            startTime = Date()
            
            timer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    if self.timeRemaining > 0 {
                        self.timeRemaining -= 1
                    } else {
                        self.completeCurrentSession()
                    }
                }
        }
    }
    
    func pauseTimer() {
        isActive = false
        timer?.cancel()
        timer = nil
    }
    
    func resetTimer() {
        pauseTimer()
        timeRemaining = isWorkSession ? workDuration : (completedPomodoros % pomodorosUntilLongBreak == 0 ? longBreakDuration : shortBreakDuration)
    }
    
    func completeCurrentSession() {
        pauseTimer()
        
        if isWorkSession {
            // Work session completed
            completedPomodoros += 1
            isWorkSession = false
            timeRemaining = (completedPomodoros % pomodorosUntilLongBreak == 0) ? longBreakDuration : shortBreakDuration
            sendNotification(title: "Work Session Complete", body: "Time for a break!")
        } else {
            // Break completed
            isWorkSession = true
            timeRemaining = workDuration
            sendNotification(title: "Break Complete", body: "Time to focus!")
        }
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // Format remaining time as mm:ss
    func formattedTimeRemaining() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
