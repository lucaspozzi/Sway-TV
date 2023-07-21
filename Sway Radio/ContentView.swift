//
//  ContentView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/10/23.
//

import SwiftUI
import CloudKit

struct ContentView: View {
    
    @StateObject var audioPlayer = AudioPlayer()
    @State private var isEventsTabEnabled = false
    private let container = CKContainer(identifier: "iCloud.app.waggie.Sway-TV")
    private let publicDatabase = CKContainer(identifier: "iCloud.app.waggie.Sway-TV").publicCloudDatabase
    private let recordType = "FeatureFlags"

    func fetchFeatureFlag(named featureName: String) {
        let predicate = NSPredicate(format: "featureName = %@", featureName)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        publicDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 1) { result in
            switch result {
            case .failure(let error):
                print("An error occurred: \(error.localizedDescription)")
            case .success((let matchResults, _)):
                if let record = matchResults.first?.1,
                   case let .success(recordData) = record,
                   let isEnabled = recordData["isEnabled"] as? Int64 {
                    DispatchQueue.main.async {
                        self.isEventsTabEnabled = isEnabled != 0
                    }
                }
            }
        }
    }


    var body: some View {
        TabView {
            
            NavigationView {
                HomeTabView()
                    .environmentObject(audioPlayer)
                    .navigationTitle("Sway Radio")
            }
            .tabItem {
                Image(systemName: "radio")
                Text("Radio")
            }
            
            NavigationView {
                RecentView()
                    .navigationTitle("Recently on air")
            }
            .tabItem {
                Image(systemName: "music.note.list")
                Text("Recent")
            }
            
            if(isEventsTabEnabled){
                NavigationView {
                    EventScheduleView()
                        .navigationTitle("Event Schedule")
                }
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Events")
                }
            }
            
        }
        .onAppear {
            fetchFeatureFlag(named: "isEventsTabEnabled")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
