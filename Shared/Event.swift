//
//  Event.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 8/8/23.
//

import Foundation

struct Event: Identifiable {
    let id: String
    let name: String
    let description: String
    let start: Date
    let end: Date
}
