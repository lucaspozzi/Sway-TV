//
//  AirPlayView.swift
//  Sway Radio
//
//  Created by Lucas Pozzi de Souza on 7/22/23.
//

import SwiftUI
import AVKit

struct AirPlayView: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let airplayButton = AVRoutePickerView()
//        airplayButton.activeTintColor = UIColor.red
//        airplayButton.tintColor = UIColor.gray
        return airplayButton
    }
    
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}


struct AirPlayView_Previews: PreviewProvider {
    static var previews: some View {
        AirPlayView()
    }
}
