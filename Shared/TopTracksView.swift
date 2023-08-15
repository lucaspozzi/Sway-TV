//
//  TopTracksView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 8/3/23.
//

import SwiftUI
import CloudKit

struct TopTracksView: View {
    
    @State private var listItems: [(String, Int)] = []
    private let sentiments = Sentiments()
    
    private func loadData() {
        sentiments.fetchTop10TrackNamesWeighted { (tracks, error) in
            if let error = error {
                print("Error fetching top tracks: \(error)")
            } else if let tracks = tracks {
                listItems = tracks
            }
        }
    }
    
    private func refreshData() async {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // Simulating a refresh delay
            loadData()
        } catch {
            print("Error during refreshData: \(error)")
        }
    }
    
    var body: some View {
        List(listItems, id: \.0) { track, count in
            HStack(alignment: .top) {
                Text(track).font(.headline)
            }
            .padding()
        }
        .onAppear {
            loadData()
        }
        .refreshable {
            await refreshData()
        }
    }
}

struct TopTracksView_Previews: PreviewProvider {
    static var previews: some View {
        TopTracksView()
    }
}
