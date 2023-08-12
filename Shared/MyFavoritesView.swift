//
//  MyFavoritesView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 8/11/23.
//

import SwiftUI
import CloudKit

struct MyFavoritesView: View {
    
    @State private var listItems: [String] = []
    private let sentiments = Sentiments()
    
    func loadData() {
        var newList: [String] = []
        sentiments.fetchUserFavorites { (tracks, error) in
            if let error = error {
                print("Error fetching top tracks: \(error)")
            } else if let tracks = tracks {
                for record in tracks {
                    if let currentTrack = record["currentTrack"] as? String {
                        newList.append(currentTrack)
                    }
                }
                listItems = newList
            }
        }
    }
    
    func refreshData() async {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // Simulating a refresh delay
            loadData()
        } catch {
            print("Error during refreshData: \(error)")
        }
    }
    
    var body: some View {
        List(listItems, id: \.self) { track in
            HStack(alignment: .top) {
                Text(track).font(.headline)
            }
            .padding()
        }
        .refreshable {
            await refreshData()
        }
        .onAppear {
            loadData()
        }
    }
}

struct MyFavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        MyFavoritesView()
    }
}
