//
//  PetClass.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 7/5/2024.
//

import Foundation
import FirebaseFirestore

/**
Class for encoding a pets information.
 - Parameters:
    - id: The pets firebase id
    - name: the pets name
    - breed: the pets breed
    - type: the pets type, ie dog/cat/other
    - acitvities: the list of the pets activities
    - reminders: the list of the pets reminders
 */

public struct PetClass: Codable {
    
    let id: String
    let name: String
    let breed: String
    let type: String
    var activities: [ActivityClass]
    var reminders: [ReminderClass]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case breed
        case type
        case activities
        case reminders
    }
}

