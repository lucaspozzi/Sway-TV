//
//  RecentView.swift
//  Sway Radio
//
//  Created by Lucas Pozzi de Souza on 7/19/23.
//

import SwiftUI

struct RecentView: View {
    
    @State private var history: [History] = []
    
    var body: some View {
        List {
            ForEach(history.indices, id: \.self) { index in
                VStack(alignment: .leading) {
                    Text(history[index].title).font(.headline)
                }
            }
        }
        .onAppear {
            fetchOnce()
        }
    }
    
    func fetchOnce() {
        
        fetchRadioStationMetadata { result in
            switch result {
            case .success(let metadata):
                DispatchQueue.main.async {
                    history = metadata.history
                }
            case .failure(let error):
                print("Error \(error)")
            }
            
        }
    }
}

struct RecentView_Previews: PreviewProvider {
    static var previews: some View {
        RecentView()
    }
}
