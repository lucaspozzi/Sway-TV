//
//  EventScheduleView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/16/23.
//

import SwiftUI
import CloudKit

struct Event: Identifiable {
    let id: String
    let name: String
    let description: String
    let start: Date
    let end: Date
}

struct EventScheduleView: View {
    @State private var newItemTitle = ""
    @State private var listItems = [Event]()
    
    private let container = CKContainer.default()
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    private let recordType = "Events"
    
    var body: some View {
        List {
            ForEach(listItems) { item in
                VStack(alignment: .leading) {
//                    Text(item.id)
                    Text(item.name)
                    Text(item.description)
                    Text("Starts \(item.start)") // Use a date formatter to format the date properly
                    Text("Ends \(item.end)")   // Use a date formatter to format the date properly
                }.padding()
            }
        }.padding()
        .onAppear(perform: fetchItems)
    }
    
    
    private func fetchItems() {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error fetching items: \(error.localizedDescription)")
            } else if let records = records {
                let items = records.compactMap { record -> Event? in
                    guard let id = record.recordID.recordName as? String else {
                        print("Failed to convert id")
                        return nil
                    }
                    guard let name = record["Name"] as? String else {
                        print("Failed to convert name")
                        return nil
                    }
                    guard let description = record["Description"] as? String else {
                        print("Failed to convert description")
                        return nil
                    }
                    guard let start = record["Start"] as? Date else {
                        print("Failed to convert start")
                        return nil
                    }
                    guard let end = record["End"] as? Date else {
                        print("Failed to convert end")
                        return nil
                    }
                    
                    return Event(id: id, name: name, description: description, start: start, end: end)
                }
                
                DispatchQueue.main.async {
                    self.listItems = items
                }
            }
        }
    }
}



struct EventScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        EventScheduleView()
    }
}
