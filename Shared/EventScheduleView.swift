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
    @State private var listItems = [Event]()
    
    private let container = CKContainer.default()
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    private let recordType = "Events"
    
    var body: some View {
        List {
            ForEach(listItems) { item in
                VStack(alignment: .leading) {
                    Text(item.name)
                    Text(item.description)
                    Text("Starts \(item.start)")
                    Text("Ends \(item.end)")
                }.padding()
            }
        }.padding()
        .onAppear(perform: fetchItems)
    }
    
    
    private func fetchItems() {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        publicDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 5) { result in
            switch result {
            case .failure(let error):
                print("Error fetching items: \(error.localizedDescription)")
            case .success((let matchResults, _)):
                let records = matchResults.compactMap { (recordId, result) -> CKRecord? in
                    do {
                        return try result.get()
                    } catch {
                        print("Error getting record \(error)")
                        return nil
                    }
                }
                let items = records.compactMap { record -> Event? in
                    let id = record.recordID.recordName
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
