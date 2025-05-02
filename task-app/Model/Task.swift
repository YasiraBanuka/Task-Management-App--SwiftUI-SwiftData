//
//  Task.swift
//  task-app
//
//  Created by Yasira Banuka on 2025-04-21.
//

import SwiftUI
import SwiftData

@Model
class Task: Identifiable {
    var id: UUID
    var taskTitle: String
    var creationDate: Date
    var isCompleted: Bool
    var tint: String
    var voiceNotePath: String?
    var voiceNoteText: String?
    
    init(id: UUID = .init(), taskTitle: String, creationDate: Date = .init(), isCompleted: Bool = false, tint: String, voiceNotePath: String? = nil, voiceNoteText: String? = nil) {
        self.id = id
        self.taskTitle = taskTitle
        self.creationDate = creationDate
        self.isCompleted = isCompleted
        self.tint = tint
        self.voiceNotePath = voiceNotePath
        self.voiceNoteText = voiceNoteText
    }
    
    var tintColor: Color {
        switch tint {
        case "TaskColor 1": return .taskColor1
        case "TaskColor 2": return .taskColor2
        case "TaskColor 3": return .taskColor3
        case "TaskColor 4": return .taskColor4
        case "TaskColor 5": return .taskColor5
        default: return .black
        }
    }
}

extension Date {
    static func updateHour(_ value: Int) -> Date {
        let calender = Calendar.current
        return calender.date(byAdding: .hour, value: value, to: .init()) ?? .init()
    }
}
