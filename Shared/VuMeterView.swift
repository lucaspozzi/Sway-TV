//
//  VuMeterView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 9/11/23.
//

import SwiftUI

struct VuMeterView: View {
    
    var hspacing: CGFloat
    var width: CGFloat
    @State private var timerAnimation: Timer? = nil
    @State var pseudoSoundLevelLeft: CGFloat = 0.1
    @State var pseudoSoundLevelRight: CGFloat = 0.1
    
    var body: some View {
        // tv HStack(spacing: 91) radio 61
        HStack(spacing: hspacing) {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    Rectangle()  // Grey rectangle in the background
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                    
                    // Colored rectangle in the foreground, its height changes with sound level
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.yellow, Color.green]), startPoint: .top, endPoint: .bottom))
                        .frame(height: geometry.size.height * pseudoSoundLevelLeft)
                        .cornerRadius(15)
                        .animation(.spring(response: 0.5, dampingFraction: 0.51, blendDuration: 0.15), value: pseudoSoundLevelLeft)
                }
            }
            .frame(width: width)  // Width of each bar radio 30 tv .frame(width: 70)
            
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    Rectangle()  // Grey rectangle in the background
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                    
                    // Colored rectangle in the foreground, its height changes with sound level
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.yellow, Color.green]), startPoint: .top, endPoint: .bottom))
                        .frame(height: geometry.size.height * pseudoSoundLevelRight)
                        .cornerRadius(15)
                        .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.10), value: pseudoSoundLevelRight)
                }
            }
            .frame(width: width)  // Width of each bar
        }
        
        .onAppear(perform: setupTimers)
        .onDisappear(perform: invalidateTimers)
    }
    
    func invalidateTimers() {
        pseudoSoundLevelLeft = 0.1
        pseudoSoundLevelRight = 0.1
        timerAnimation?.invalidate()
    }
    
    func setupTimers() {
        timerAnimation = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            // Generate a pseudo-random sound level between 0.0 and 1.0 for each channel
            pseudoSoundLevelLeft = CGFloat.random(in: 0.55...0.90)
            pseudoSoundLevelRight = CGFloat.random(in: 0.60...0.95)
        }
    }
}

struct VuMeterView_Previews: PreviewProvider {
    static var previews: some View {
        VuMeterView(hspacing: 61, width: 30)
    }
}
