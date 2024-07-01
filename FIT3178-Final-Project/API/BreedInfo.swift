//
//  BreedInfo.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 2/6/2024.
//

import Foundation

/**
 Class for decoding breed data from breed api.
 
 - Parameters:
 - name: The breeds name
 */

public struct BreedInfo: Codable {
    
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}
