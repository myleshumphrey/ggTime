//
//  JoinTimePickerView.swift
//  GG Time
//
//  SwiftUI view for selecting a different join time when joining a gaming session.
//

import SwiftUI

/// View for selecting a different join time
struct JoinTimePickerView: View {
    
    // MARK: - Properties
    
    /// The selected join time
    @State private var joinTime: Date = Date().addingTimeInterval(3600) // Default: 1 hour from now
    
    /// Callback when user confirms their join time
    let onConfirm: (Date) -> Void
    
    /// Callback when user cancels
    let onCancel: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Join at Different Time")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("When will you be able to join?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Time picker section
                VStack(alignment: .leading, spacing: 12) {
                    Label("Your join time", systemImage: "clock")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    DatePicker(
                        "Join Time",
                        selection: $joinTime,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding(.vertical, 8)
                    
                    // Time preview
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text(formatDateTime(joinTime))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        onConfirm(joinTime)
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Join at This Time")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: onCancel) {
                        Text("Cancel")
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Formats a date/time in a friendly way
    private func formatDateTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = "'Today at' h:mm a"
        } else if calendar.isDateInTomorrow(date) {
            dateFormatter.dateFormat = "'Tomorrow at' h:mm a"
        } else {
            dateFormatter.dateFormat = "MMM d 'at' h:mm a"
        }
        
        return dateFormatter.string(from: date)
    }
}

// MARK: - Preview

#if DEBUG
struct JoinTimePickerView_Previews: PreviewProvider {
    static var previews: some View {
        JoinTimePickerView(
            onConfirm: { time in
                print("Confirmed join time: \(time)")
            },
            onCancel: {
                print("Cancelled")
            }
        )
    }
}
#endif
