//
//  UserClass.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 2/5/2024.
//

import Foundation
import FirebaseFirestoreSwift
/**
Class for encoding a users information.
 - Parameters:
    - id: The users id
    - name: the users name
    - email: the users email
    - pets: the list of the users pets
 */

public struct UserClass: Codable {
    
    let id: String
    let email: String
    let name: String
    let pets: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case pets
    }
}

