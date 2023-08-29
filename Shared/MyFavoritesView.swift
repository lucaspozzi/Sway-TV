//
//  MyFavoritesView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 8/11/23.
//

import SwiftUI
import CloudKit

struct MyFavoritesView: View {
    
    struct TrackItem: Identifiable {
        let id = UUID()
        let trackName: String
        var artURL: String
    }
    
    @State private var trackItems: [TrackItem] = []
    private let sentiments = Sentiments()
    private let defaultArtwork: UIImage = UIImage(named: "audiodog")!
    
    func loadData() {
        var newList: [TrackItem] = []
        sentiments.fetchUserFavorites { (tracks, error) in
            if let error = error {
                print("Error fetching top tracks: \(error)")
            } else if let tracks = tracks {
                for record in tracks {
                    if let trackName = record["trackName"] as? String,
                       let artURL = record["artUrl"] as? String {
                        newList.append(TrackItem(trackName: trackName, artURL: artURL))
                    }
                }
                trackItems = newList
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
        List(trackItems) { item in
            HStack(alignment: .top) {
                if let url = URL(string: item.artURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty, .failure:
                            defaultImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .cornerRadius(8) // Apply corner radius for image
                                .padding(.trailing, 10)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .cornerRadius(8) // Apply corner radius for image
                                .padding(.trailing, 10)
                        @unknown default:
                            defaultImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .cornerRadius(8) // Apply corner radius for image
                                .padding(.trailing, 10)
                        }
                    }
                }
                VStack(alignment: .leading) {
                    Text(item.trackName).multilineTextAlignment(.leading)
                        .font(.headline)
                        .lineLimit(3)
                }
            }
            .padding(.vertical, 8)
        }
        .refreshable {
            await refreshData()
        }
        .onAppear {
            loadData()
        }
    }
    
    private var defaultImage: Image {
        Image(uiImage: defaultArtwork)
    }
}


struct MyFavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        MyFavoritesView()
    }
}
