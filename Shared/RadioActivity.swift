//
//  RadioActivity.swift
//  Sway Radio
//
//  Created by Lucas Pozzi de Souza on 7/22/23.
//

import Foundation
import GroupActivities
import SwiftUI

struct RadioActivity: GroupActivity {
    
    static let activityIdentifier = "app.waggie.Sway-TV.radio"
    
    let isPlaying: Bool
    
    var metadata: GroupActivityMetadata {
        let title = NSLocalizedString("Listening to Sway Radio", comment: "")
        let previewImage = UIImage(named: "audiodog")!.cgImage
        let audioDescription = NSLocalizedString("Join me for a radio session!", comment: "")
        
        var metadata = GroupActivityMetadata()
        metadata.title = title
        metadata.previewImage = previewImage
        metadata.subtitle = audioDescription
        return metadata
    }
    
    struct SessionData: Codable {
        let url: URL
    }
    
    let sessionData: SessionData
    
    func isEqual(to other: RadioActivity) -> Bool {
        return sessionData.url == other.sessionData.url
    }
}
