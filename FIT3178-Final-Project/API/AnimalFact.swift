//
//  AnimalFact.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 3/6/2024.
//

import Foundation

/**
 Class for decoding fact data from fact api.
 
 - Parameters:
 - fact: the fact retrieved
 */

public struct AnimalFact: Codable {
    
    let fact: String
    
    enum CodingKeys: String, CodingKey {
        case fact
    }
}
