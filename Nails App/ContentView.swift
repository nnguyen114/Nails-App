import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.date, order: .reverse) private var services: [Item]
    
    @State private var selectedTechnicianName = ""
    @State private var serviceName = ""

    // Hardcoded list of technician names
    private let technicianNames = ["Trang", "Al", "Cindy", "Kathy"]

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(services) { service in
                        VStack(alignment: .leading) {
                            Text(service.technicianName)
                                .font(.headline)
                            Text(service.serviceName)
                            Text("Date: \(service.date, style: .date)")
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                deleteService(service)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                
                Divider()
                
                VStack {
                    Picker("Technician Name", selection: $selectedTechnicianName) {
                        ForEach(technicianNames, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

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
            .navigationBarTitleDisplayMode(.inline)  // You can also use .large if you want a large title
        }
    }
    
    private func addService() {
        // Insert new service entry
        let newItem = Item(technicianName: selectedTechnicianName, serviceName: serviceName)
        modelContext.insert(newItem)
        
        // Clear input fields after adding the service
        selectedTechnicianName = ""
        serviceName = ""
    }

    private func deleteService(_ service: Item) {
        modelContext.delete(service)
        
        // Save changes to the context, if needed
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context after deletion: \(error)")
        }
    }
}
