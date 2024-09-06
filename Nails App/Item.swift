import SwiftData
import Foundation

@Model
class Item: Identifiable {
    var id: UUID
    var technicianName: String
    var serviceName: String
    var customerName: String
    var date: Date
    var price: Double // Added to store the price of the service
    var isAvailable: Bool

    init(technicianName: String, serviceName: String, customerName: String, price: Double, date: Date = Date(), isAvailable: Bool = true) {
        self.id = UUID()
        self.technicianName = technicianName
        self.serviceName = serviceName
        self.customerName = customerName
        self.price = price
        self.date = date
        self.isAvailable = isAvailable
    }
}
