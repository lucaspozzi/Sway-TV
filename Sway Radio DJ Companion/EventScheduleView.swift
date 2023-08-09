//
//  EventScheduleView.swift
//  Sway Radio DJ Companion
//
//  Created by Lucas Pozzi de Souza on 8/8/23.
//

import SwiftUI
import CloudKit

struct EventScheduleView: View {
    @State private var listItems = [Event]()
    @State private var showAddEventView = false
    @State private var message: String = "No events found."
    private let container = CKContainer(identifier: "iCloud.app.waggie.Sway-TV")
    private let publicDatabase = CKContainer(identifier: "iCloud.app.waggie.Sway-TV").publicCloudDatabase
    private let recordType = "Events"
    // Other properties
    
    var body: some View {
        NavigationView {
            List {
                ForEach(listItems) { item in
                    VStack(alignment: .leading) {
                        Text(item.name).font(.headline)
                        Text(item.description)
                        Text("Starts \(formatDate(date: item.start))")
                        Text("Ends \(formatDate(date: item.end))")
                    }//.padding()
                }
                .onDelete(perform: deleteItems) // Enable swipe to delete
            }
            .navigationTitle("Event Schedule")
            .navigationBarItems(trailing: Button("Add Event") {
                showAddEventView = true
            })
            .sheet(isPresented: $showAddEventView) {
                AddEventView(showAddEventView: $showAddEventView, listItems: $listItems)
            }
        }
        .onAppear(perform: fetchItems)
    }
    
    private func deleteItems(at offsets: IndexSet) {
        // Logic to delete items from CloudKit and update local list
    }
    
    private func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d 'at' ha zzz"
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    private func fetchItems() {
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) as NSDate?
        let predicate = NSPredicate(format: "Start > %@", yesterday ?? NSDate())
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        publicDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 5) { result in
            switch result {
            case .failure(let error):
                self.message = error.localizedDescription
                print("Error fetching items: \(error.localizedDescription)")
            case .success((let matchResults, _)):
                let records = matchResults.compactMap { (recordId, results) -> CKRecord? in
                    do {
                        return try results.get()
                    } catch {
                        self.message = error.localizedDescription
                        print("Error getting record \(error)")
                        return nil
                    }
                }
                let items = records.compactMap { record -> Event? in
                    let id = record.recordID.recordName
                    guard let name = record["Name"] as? String else {
                        self.message = "Failed to convert name"
                        print("Failed to convert name")
                        return nil
                    }
                    guard let description = record["Description"] as? String else {
                        self.message = "Failed to convert description"
                        print("Failed to convert description")
                        return nil
                    }
                    guard let start = record["Start"] as? Date else {
                        self.message = "Failed to convert start"
                        return nil
                    }
                    guard let end = record["End"] as? Date else {
                        self.message = "Failed to convert end"
                        print("Failed to convert end")
                        return nil
                    }
                    
                    return Event(id: id, name: name, description: description, start: start, end: end)
                }
                let sortedItems = items.sorted {
                    $0.start < $1.start
                }
                
                self.listItems = sortedItems
            }
        }
    }
}

struct AddEventView: View {
    @Binding var showAddEventView: Bool
    @Binding var listItems: [Event]
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var start: Date = Date()
    @State private var end: Date = Date()
    
    private let container = CKContainer(identifier: "iCloud.app.waggie.Sway-TV")
    private let publicDatabase = CKContainer(identifier: "iCloud.app.waggie.Sway-TV").publicCloudDatabase
    private let recordType = "Events"
    // Add more properties as needed
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Description", text: $description)
                DatePicker("Start Time", selection: $start)
                DatePicker("End Time", selection: $end)
                // Add more fields as needed
//                Button("Add Event") {
//                    addEvent() // Function to add the event
//                }
            }
            .navigationBarItems(trailing: Button("Save") {
                addEvent()
            })
        }
        
        
    }
    
    private func addEvent() {
        let event = Event(id: UUID().uuidString, name: name, description: description, start: start, end: end)
        listItems.append(event)
        // Logic to save the event to CloudKit
        add(name: name, description: description, start: start, end: end)
        
        showAddEventView = false // Close this view
    }
    
    func add(name: String, description: String, start: Date, end: Date) {
        // Create a new CKRecord
        let recordID = CKRecord.ID(recordName: UUID().uuidString)
        let newRecord = CKRecord(recordType: recordType, recordID: recordID)
        
        // Set the desired fields
        newRecord["Name"] = name
        newRecord["Description"] = description
        newRecord["Start"] = start
        newRecord["End"] = end
        
        // Create a CKModifyRecordsOperation
        let modifyOp = CKModifyRecordsOperation(recordsToSave: [newRecord], recordIDsToDelete: nil)
        modifyOp.savePolicy = .allKeys
        
        modifyOp.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if let error = error {
                print("CloudKit \(self.recordType) Save Error: \(error)")
            } else if let savedRecords = savedRecords, savedRecords.count > 0 {
                print("Successfully saved \(self.recordType) record to CloudKit")
            }
        }
        
        publicDatabase.add(modifyOp)
    }
}
