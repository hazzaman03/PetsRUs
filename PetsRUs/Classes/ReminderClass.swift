//
//  ReminderClass.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 9/5/2024.
//

import Foundation
/**
Class for encoding a activities information.
 - Parameters:
    - title: the pets name
    - dueDate: the date the activity is due
    - repeats: whether the reminder repeats
    - createdBy: the user who created the activity
 */

public struct ReminderClass: Codable {
    var title: String
    var dueDate: Int64
    var repeats: String
    var createdBy: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case dueDate
        case repeats
        case createdBy
    }
}
