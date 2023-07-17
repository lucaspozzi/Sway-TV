//
//  StartSharePlayView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/16/23.
//

import SwiftUI

struct StartSharePlayView: View {
    var body: some View {
        Button(action: {
            print("clicked")
        }) {
            HStack {
                Image(systemName: "shareplay").resizable().aspectRatio(contentMode: .fit)
                Text("Start SharePlay")
            }
        }
        .frame(height: 190)
    }
}

struct StartSharePlayView_Previews: PreviewProvider {
    static var previews: some View {
        StartSharePlayView()
    }
}
