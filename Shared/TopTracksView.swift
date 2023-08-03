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
    
    var body: some View {
        List(listItems, id: \.0) { track, count in
            HStack(alignment: .top) {
                Text(track).font(.headline)
//                Spacer()
//                Text("Sways: \(count)")
            }
            .padding()
        }
        .onAppear {
            sentiments.fetchTop10TrackNamesWeighted { (tracks, error) in
                if let error = error {
                    print("Error fetching top tracks: \(error)")
                } else if let tracks = tracks {
                    listItems = tracks
                }
            }
        }
    }
}

struct TopTracksView_Previews: PreviewProvider {
    static var previews: some View {
        TopTracksView()
    }
}
