import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.date, order: .reverse) private var services: [Item]
    @State private var historicalServices: [Item] = []

    @State private var selectedTechnicianName: String? = nil
    @State private var serviceName = ""

    private var allTechnicianNames = ["Trang", "Al", "Cindy", "Kathy"]

    private var availableTechnicianNames: [String] {
        let unavailableNames = Set(services.filter { !$0.isAvailable }.map { $0.technicianName })
        return allTechnicianNames.filter { !unavailableNames.contains($0) }
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Current Services")) {
                        ForEach(services) { service in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(service.technicianName)
                                        .font(.headline)
                                    
                                    if !service.isAvailable {
                                       
                                    }
                                }
                                Text(service.serviceName)
                                Text("Date: \(service.date, style: .date)")
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    moveToHistory(service)  // Move to history instead of deleting
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("History")) {
                        ForEach(historicalServices) { historicalService in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(historicalService.technicianName)
                                        .font(.headline)
                                    
                                    if !historicalService.isAvailable {
                                        
                                    }
                                }
                                Text(historicalService.serviceName)
                                Text("Date: \(historicalService.date, style: .date)")
                            }
                        }
                    }
                }

                Divider()

                VStack {
                    Picker("Technician Name", selection: $selectedTechnicianName) {
                        Text("Select a Technician").tag(String?.none) // Placeholder
                        ForEach(availableTechnicianNames, id: \.self) { name in
                            Text(name).tag(name as String?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedTechnicianName) { newValue in
                        if let technicianName = newValue {
                            markTechnicianAsUnavailable(technicianName)
                        }
                    }

                    TextField("Service Name", text: $serviceName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: addService) {
                        Text("Add Service")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Beverly Nails")
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func addService() {
        guard let selectedTechnicianName = selectedTechnicianName, !selectedTechnicianName.isEmpty else {
            print("No technician selected or selection is invalid")
            return
        }
        
        if !availableTechnicianNames.contains(selectedTechnicianName) {
            print("Selected technician is not available")
            return
        }

        let newItem = Item(technicianName: selectedTechnicianName, serviceName: serviceName, date: Date(), isAvailable: false)
        modelContext.insert(newItem)
        self.selectedTechnicianName = nil
        serviceName = ""
    }

    private func moveToHistory(_ service: Item) {
        // Remove from current services and add to historical services
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
    
    private func markTechnicianAsUnavailable(_ technicianName: String) {
        let technicianServices = services.filter { $0.technicianName == technicianName }
        technicianServices.forEach { service in
            var updatedService = service
            updatedService.isAvailable = false
            saveContext()
        }
    }
}
