import SwiftUI
import SwiftData

extension Color {
    static let pastelPurple = Color(red: 229/255, green: 204/255, blue: 255/255)
    static let darkerPurple = Color(red: 119/255, green: 84/255, blue: 122/255)
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.date, order: .reverse) private var services: [Item]
    @State private var historicalServices: [Item] = []
    @State private var selectedTechnicianName: String? = nil  // Optional String for manual selection
    @State private var serviceName = ""
    @State private var servicePrice = ""  // For price input
    @State private var showingTotalAlert = false
    @State private var currentTechnician = ""
    
    // Initial queue of all technician names
    @State private var technicianQueue: [String] = ["Trang", "Al", "Cindy", "Kathy"]

    // Filter the technicians who are currently not assigned to any active service
    private var availableTechnicianQueue: [String] {
        let assignedTechnicians = Set(services.map { $0.technicianName })
        return technicianQueue.filter { !assignedTechnicians.contains($0) } // Only technicians not currently working
    }

    // Next technician in queue
    private var nextTechnician: String? {
        availableTechnicianQueue.first // Auto-select from available technicians
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Current Services")) {
                        ForEach(services) { service in
                            VStack(alignment: .leading) {
                                Text(service.technicianName)
                                    .font(.headline)
                                    .foregroundColor(.darkerPurple)  // White text on purple background
                                Text(service.serviceName)
                                    .foregroundColor(.darkerPurple)
                                Text("Price: $\(service.price, specifier: "%.2f")")
                                    .foregroundColor(.darkerPurple)
                                Text("Date: \(service.date, style: .date)")
                                    .foregroundColor(.darkerPurple)
                            }
                            .padding()
                            .background(Color.pastelPurple)
                            .cornerRadius(10)
                            .swipeActions {
                                Button(role: .destructive) {
                                    moveToHistory(service)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .onTapGesture {
                                showingTotalAlert = true
                                currentTechnician = service.technicianName
                            }
                        }
                    }
                    
                    Section(header: Text("History")) {
                        ForEach(historicalServices) { historicalService in
                            VStack(alignment: .leading) {
                                Text(historicalService.technicianName)
                                    .font(.headline)
                                    .foregroundColor(.darkerPurple)
                                Text(historicalService.serviceName)
                                    .foregroundColor(.darkerPurple)
                                Text("Price: $\(historicalService.price, specifier: "%.2f")")
                                    .foregroundColor(.darkerPurple)
                                Text("Date: \(historicalService.date, style: .date)")
                                    .foregroundColor(.darkerPurple)
                            }
                            .padding()
                            .background(Color.pastelPurple)
                            .cornerRadius(10)
                        }
                    }
                }
                .alert(isPresented: $showingTotalAlert) {
                    Alert(
                        title: Text("Total Sales for Today"),
                        message: Text("Total sales for \(currentTechnician): $\(totalSales(for: currentTechnician), specifier: "%.2f")"),
                        dismissButton: .default(Text("OK"))
                    )
                }

                Divider()

                VStack {
                    // Show the next available technician if none is selected manually
                    if let nextTechnician = nextTechnician, selectedTechnicianName == nil {
                        Text("Next technician: \(nextTechnician)")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.bottom, 8)
                            .foregroundColor(.darkerPurple)
                    }

                    Picker("Technician Name", selection: $selectedTechnicianName) {
                        Text("Auto-Select")
                            .foregroundColor(.darkerPurple)
                            .font(.headline)
                            .tag(String?.none)  // This allows auto-selection
                        ForEach(availableTechnicianQueue, id: \.self) { name in
                            Text(name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.pastelPurple)

                    TextField("Service Name", text: $serviceName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.darkerPurple)

                    TextField("Service Price", text: $servicePrice)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.darkerPurple)

                    Button(action: addService) {
                        Text("Add Service")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.darkerPurple)
                            .foregroundColor(.pastelPurple)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Beverly Nails")
                        .font(.system(size: 28, weight: .bold))  // Increase font size to 28
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.darkerPurple)
                }
            }
            .background(Color.pastelPurple.edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Function to calculate total sales from both active and historical services
    private func totalSales(for technicianName: String) -> Double {
        let today = Calendar.current.startOfDay(for: Date()) // Get the start of today
        
        // Combine both current and historical services
        let allServices = services + historicalServices
        
        let sales = allServices.filter { service in
            service.technicianName == technicianName &&
            Calendar.current.isDate(service.date, inSameDayAs: today) // Filter by today's date
        }
        
        return sales.reduce(0) { $0 + $1.price } // Sum the price of all services
    }

    // Function to add a new service
    private func addService() {
        // Check if a technician is manually selected or auto-select the next in queue
        let technicianToAssign = selectedTechnicianName ?? nextTechnician
        
        guard let technicianName = technicianToAssign,
              let price = Double(servicePrice),
              !technicianName.isEmpty,
              price > 0 else {
            print("Invalid inputs")
            return
        }

        // Add the new service to the list
        let newItem = Item(technicianName: technicianName, serviceName: serviceName, customerName: "", price: price, date: Date(), isAvailable: false)
        modelContext.insert(newItem)

        // Reset the manually selected technician (if any)
        selectedTechnicianName = nil

        // Rotate the queue only if auto-selected
        if technicianToAssign == nextTechnician {
            rotateTechnicianQueue()
        }

        // Clear fields
        serviceName = ""
        servicePrice = ""
    }

    // Function to rotate the technician queue (move first to last)
    private func rotateTechnicianQueue() {
        if !technicianQueue.isEmpty {
            let firstTechnician = technicianQueue.removeFirst()
            technicianQueue.append(firstTechnician)
        }
    }

    private func moveToHistory(_ service: Item) {
        if let index = services.firstIndex(where: { $0.id == service.id }) {
            var updatedService = services[index]
            modelContext.delete(service)
            historicalServices.append(updatedService)
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
