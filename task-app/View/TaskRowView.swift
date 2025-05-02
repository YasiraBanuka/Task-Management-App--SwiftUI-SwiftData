//
//  TaskRowView.swift
//  task-app
//
//  Created by Yasira Banuka on 2025-04-21.
//

import SwiftUI
import UserNotifications

struct TaskRowView: View {
    @Bindable var task: Task
    /// Model Context
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var pomodoroTimer: PomodoroTimer
    @State private var showPomodoroView: Bool = false
    @State private var showVoiceNoteView: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(indicatorColor)
                .frame(width: 10, height: 10)
                .padding(4)
                .background(.white.shadow(.drop(color: .black.opacity(0.1), radius: 3)), in: .circle)
                .overlay {
                    Circle()
                        .foregroundStyle(.clear)
                        .contentShape(.circle)
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            let wasCompleted = task.isCompleted
                            
                            withAnimation(.snappy) {
                                task.isCompleted.toggle()
                            }
                            
                            // If the task was just completed (not uncompleted), show notification
                            if !wasCompleted && task.isCompleted {
                                scheduleCompletionNotification(for: task)
                            }
                        }
                }
            
            VStack(alignment: .leading, spacing: 8, content: {
                Text(task.taskTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                
                Label(task.creationDate.format("hh:mm a"), systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.black)
                
                // Show voice note indicator if one exists
                                if task.voiceNotePath != nil {
                                    Label("Voice Note", systemImage: "waveform")
                                        .font(.caption)
                                        .foregroundStyle(.black)
                                        .onTapGesture {
                                            showVoiceNoteView.toggle()
                                        }
                                }
                                
                                // Action buttons row
                                if !task.isCompleted {
                                    HStack(spacing: 12) {
                                        // Pomodoro Button
                                        Button {
                                            showPomodoroView.toggle()
                                        } label: {
                                            Label(
                                                pomodoroTimer.currentTaskId == task.id && pomodoroTimer.isActive ?
                                                pomodoroTimer.formattedTimeRemaining() : "Focus",
                                                systemImage: "timer"
                                            )
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.white.opacity(0.3))
                                            .cornerRadius(8)
                                        }
                                        .sheet(isPresented: $showPomodoroView) {
                                            PomodoroView(task: task)
                                                .presentationDetents([.height(400)])
                                                .presentationBackground(.BG)
                                        }
                                        
                                        // Voice Note Button
                                        Button {
                                            showVoiceNoteView.toggle()
                                        } label: {
                                            Label("Voice", systemImage: "mic")
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.white.opacity(0.3))
                                                .cornerRadius(8)
                                        }
                                        .sheet(isPresented: $showVoiceNoteView) {
                                            VoiceNoteView(task: task)
                                                .presentationDetents([.medium, .large])
                                                .presentationBackground(.BG)
                                        }
                                        
                                        // Show indicator if timer is active for this task
                                        if pomodoroTimer.currentTaskId == task.id && pomodoroTimer.isActive {
                                            Circle()
                                                .fill(pomodoroTimer.isWorkSession ? Color.red : Color.green)
                                                .frame(width: 8, height: 8)
                                                .padding(.leading, -4)
                                        }
                                    }
                                }
            })
            .padding(15)
            .hSpacing(.leading)
            .background(task.tintColor, in: .rect(topLeadingRadius: 15, bottomLeadingRadius: 15))
            .strikethrough(task.isCompleted, pattern: .solid, color: .black)
            .contentShape(.contextMenuPreview, .rect(cornerRadius: 15))
            .contextMenu {
                if task.voiceNotePath != nil {
                                    Button("Play Voice Note") {
                                        showVoiceNoteView.toggle()
                                    }
                                } else {
                                    Button("Add Voice Note") {
                                        showVoiceNoteView.toggle()
                                    }
                                }
                
                Button("Delete Task", role: .destructive) {
                    /// Deleting task
                    context.delete(task)
                    try? context.save()
                }
            }
            .offset(y: -8)
        }
    }
    
    var indicatorColor: Color {
        if task.isCompleted {
            return .green
        }
        
        return task.creationDate.isSameHour ? .darkBlue : (task.creationDate.isPast ? .red : .black)
    }
    
    func scheduleCompletionNotification(for task: Task) {
        let content = UNMutableNotificationContent()
        content.title = "Task Completed"
        content.body = "You've completed: \(task.taskTitle)"
        content.sound = .default
        
        // create trigger (deliver immediately)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // create request
        let request = UNNotificationRequest(
            identifier: "task-completed-\(task.id)",
            content: content,
            trigger: trigger
        )
        
        // add request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notitication: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
