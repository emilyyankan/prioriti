//
//  ContentView.swift
//  Prioriti
//
//  Created by Emily Kan on 6/25/25.
//

import SwiftUI
import UserNotifications

struct Reminder: Identifiable, Codable {
    var id = UUID()
    var title: String
    var date: Date
}

struct ContentView: View {
    @State var reminders: [Reminder] = []
    @State var newReminderTitle: String = ""
    @State var newReminderDate: Date = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add New Reminder")
                        .font(.headline)
                    
                    TextField("What do you want to remember?", text: $newReminderTitle)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    
                    DatePicker("Reminder Time", selection: $newReminderDate, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .padding(.vertical, 5)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                
                // Button
                Button(action: addReminder) {
                    Label("Add Reminder", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(newReminderTitle.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.headline)
                }
                .disabled(newReminderTitle.isEmpty)
                .padding(.horizontal)
                
                // Reminder List or Empty State
                if reminders.isEmpty {
                    Spacer()
                    Text("No reminders yet. You are all caught up!")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(reminders.indices, id: \.self) { index in
                            let reminder = reminders[index]
                            VStack(alignment: .leading, spacing: 4) {
                                Text(reminder.title)
                                    .font(.headline)
                                    .foregroundColor(isOverdue(reminder) ? .red : .primary)
                                
                                Text(reminder.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                            .contentShape(Rectangle())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            
                            // Swipe to delete
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    reminders.remove(at: index)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Prioriti")
            .onAppear(perform: requestNotificationPermission)
        }
    }
    
    
    func addReminder() {
        let reminder = Reminder(title: newReminderTitle, date: newReminderDate)
        reminders.append(reminder)
        newReminderTitle = ""
        newReminderDate = Date()
    }
    
    func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "Prioriti Reminder"
        content.body = reminder.title
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    func isOverdue(_ reminder: Reminder) -> Bool {
        return reminder.date < Date()
    }
}

#Preview {
    ContentView()
}
