//
//  ActivityClass.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 9/5/2024.
//

import Foundation
import FirebaseFirestore
/**
Class for encoding a activities information.
 - Parameters:
    - title: the pets name
    - notes: the notes for the activity
    - category: the category for activity, ie food/exercise/groom etc.
    - dateCompleted: the date the activity was completed
    - createdBy: the user who created the activity
 */

public struct ActivityClass: Codable {
    var title: String
    var notes: String
    var category: String
    var dateCompleted: Int64
    var createdBy: String
    
    
    enum CodingKeys: String, CodingKey {
        case title
        case notes
        case category
        case dateCompleted
        case createdBy
    }
}
