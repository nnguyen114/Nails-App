import SwiftData
import Foundation

@Model
class Item: Identifiable {  // Identifiable to be used in SwiftUI lists
    var id: UUID
    var technicianName: String
    var serviceName: String
    var date: Date

    // Required initializer for a class
    init(technicianName: String, serviceName: String) {
        self.id = UUID()  // Assign a unique UUID automatically
        self.technicianName = technicianName
        self.serviceName = serviceName
        self.date = Date()  // Set current date
    }
}
