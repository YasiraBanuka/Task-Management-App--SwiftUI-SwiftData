//
//  TasksView.swift
//  task-app
//
//  Created by Yasira Banuka on 2025-05-02.
//

import SwiftUI
import SwiftData

struct TasksView: View {
    @Binding var currentDate: Date
    /// SwiftData dynamic query
    @Query private var tasks: [Task]
    init(currentDate: Binding<Date>) {
        self._currentDate = currentDate
        /// Predicate
        let calender = Calendar.current
        let startDate = calender.startOfDay(for: currentDate.wrappedValue)
        let endOfDate = calender.date(byAdding: .day, value: 1, to: startDate)!
        let predicate = #Predicate<Task> {
            return $0.creationDate >= startDate && $0.creationDate < endOfDate
        }
        /// Sorting
        let sortDescriptor = [
            SortDescriptor(\Task.creationDate, order: .forward)
        ]
        self._tasks = Query(filter: predicate, sort: sortDescriptor, animation: .snappy)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 35) {
            ForEach(tasks) { task in
                TaskRowView(task: task)
                    .background(alignment: .leading) {
                        if tasks.last?.id != task.id {
                            Rectangle()
                                .frame(width: 1)
                                .offset(x: 8)
                                .padding(.bottom, -35)
                        }
                    }
            }
        }
        .padding([.vertical, .leading], 15)
        .padding(.top, 15)
        .overlay {
            if tasks.isEmpty {
                Text("No Tasks Found")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .frame(width: 150)
            }
        }
    }
}

#Preview {
    ContentView()
}
