//
//  CustomSlider.swift
//  Sway Radio
//
//  Created by Lucas Pozzi de Souza on 7/22/23.
//

import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Slider
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                    Rectangle()
                        .frame(width: CGFloat(self.value / 100) * geometry.size.width)
                        .cornerRadius(15)
                }
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { dragValue in
                        // Calculate new value, but limit it to be between 0 and 100
                        let newValue = Double(dragValue.location.x / geometry.size.width) * 100
                        self.value = min(max(newValue, 0), 100)
                    })
                
                // Speaker icons
                HStack {
                    Image(systemName: "speaker.minus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(.leading, 10).disabled(true)
                    Spacer()
                    Image(systemName: "speaker.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 10).disabled(true)
                }
            }
        }
        .frame(height: 30)
    }
}


//struct CustomSlider_Previews: PreviewProvider {
//    @State var value: Double = 40.0
//    static var previews: some View {
////        self.value = 40.0
////        CustomSlider(value: $value)
//    }
//}
