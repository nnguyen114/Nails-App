import SwiftData
import Foundation

@Model
class Item: Identifiable {  // Identifiable to be used in SwiftUI lists
    var id: UUID
    var technicianName: String
    var serviceName: String
    var date: Date
    var isAvailable: Bool

    // Required initializer for a class
    init(technicianName: String, serviceName: String, date: Date, isAvailable: Bool) {
        self.id = UUID()  // Assign a unique UUID automatically
        self.technicianName = technicianName
        self.serviceName = serviceName
        self.date = date  // Use the date parameter provided
        self.isAvailable = isAvailable  // Set based on the provided value
    }
}
