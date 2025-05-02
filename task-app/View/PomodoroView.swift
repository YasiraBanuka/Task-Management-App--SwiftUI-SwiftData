//
//  PomodoroView.swift
//  task-app
//
//  Created by Yasira Banuka on 2025-05-02.
//

import SwiftUI

struct PomodoroView: View {
    var task: Task
    @EnvironmentObject private var pomodoroTimer: PomodoroTimer
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Pomodoro Timer")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    pomodoroTimer.resetTimer()
                } label: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            // Task title
            Text(task.taskTitle)
                .font(.headline)
                .padding(.top, 10)
            
            // Timer display
            ZStack {
                Circle()
                    .stroke(
                        pomodoroTimer.isWorkSession ? Color.red.opacity(0.3) : Color.green.opacity(0.3),
                        lineWidth: 15
                    )
                    .frame(width: 250, height: 250)
                
                Circle()
                    .trim(from: 0, to: progressValue())
                    .stroke(
                        pomodoroTimer.isWorkSession ? Color.red : Color.green,
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: pomodoroTimer.timeRemaining)
                
                VStack(spacing: 10) {
                    Text(pomodoroTimer.isWorkSession ? "Focus" : "Break")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Text(pomodoroTimer.formattedTimeRemaining())
                        .font(.system(size: 44, weight: .bold))
                    
                    if pomodoroTimer.isWorkSession {
                        Text("\(pomodoroTimer.completedPomodoros) pomodoros completed")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 20)
            
            // Timer controls
            HStack(spacing: 30) {
                Button {
                    if pomodoroTimer.isActive {
                        pomodoroTimer.pauseTimer()
                    } else {
                        pomodoroTimer.startTimer(taskId: task.id)
                    }
                } label: {
                    Image(systemName: pomodoroTimer.isActive ? "pause.fill" : "play.fill")
                        .font(.title)
                        .frame(width: 60, height: 60)
                        .background(pomodoroTimer.isWorkSession ? Color.red.opacity(0.15) : Color.green.opacity(0.15))
                        .foregroundColor(pomodoroTimer.isWorkSession ? .red : .green)
                        .clipShape(Circle())
                }
                
                Button {
                    pomodoroTimer.completeCurrentSession()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title)
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.gray)
                        .clipShape(Circle())
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            // Activate timer for this task if not already running
            if pomodoroTimer.currentTaskId != task.id {
                pomodoroTimer.currentTaskId = task.id
                pomodoroTimer.resetTimer()
            }
        }
    }
    
    private func progressValue() -> CGFloat {
        let totalTime = pomodoroTimer.isWorkSession
        ? pomodoroTimer.workDuration
        : (pomodoroTimer.completedPomodoros % pomodoroTimer.pomodorosUntilLongBreak == 0
           ? pomodoroTimer.longBreakDuration
           : pomodoroTimer.shortBreakDuration)
        
        return CGFloat(Double(totalTime - pomodoroTimer.timeRemaining) / Double(totalTime))
    }
}

#Preview {
    PomodoroView(task: Task(taskTitle: "Sample Task", tint: "TaskColor 1"))
        .environmentObject(PomodoroTimer())
}
