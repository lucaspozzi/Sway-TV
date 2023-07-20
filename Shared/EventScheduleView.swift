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
    @State private var message: String = "No events found."
    private let container = CKContainer(identifier: "iCloud.app.waggie.Sway-TV")
    private let publicDatabase = CKContainer(identifier: "iCloud.app.waggie.Sway-TV").publicCloudDatabase
    private let recordType = "Events"
    
    var body: some View {
        
        List {
            ForEach(listItems) { item in
                VStack(alignment: .leading) {
                    Text(item.name).font(.headline)
                    Text(item.description)
                    Text("Starts \(formatDate(date: item.start))")
                    Text("Ends \(formatDate(date: item.end))")
                }
            }
            if(listItems.isEmpty){
                Text(message).font(.title)
            }
        }
        .onAppear(perform: fetchItems)
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
                self.message = ""
                self.listItems = sortedItems
            }
        }
    }
}



struct EventScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        EventScheduleView()
    }
}
