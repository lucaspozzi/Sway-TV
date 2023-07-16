//
//  HomeTabView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/16/23.
//

import SwiftUI

struct HomeTabView: View {
    var body: some View {
        VStack {
            AudioPlayerView()
            HStack {
                AmbientVideoMenuView()
                StartSharePlayView()
            }
        }
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}
