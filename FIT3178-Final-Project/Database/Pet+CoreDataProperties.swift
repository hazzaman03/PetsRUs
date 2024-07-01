//
//  Pet+CoreDataProperties.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 5/6/2024.
//
//

import Foundation
import CoreData

/// NSObject for pet
extension Pet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pet> {
        return NSFetchRequest<Pet>(entityName: "Pet")
    }

    @NSManaged public var name: String?
    @NSManaged public var breed: String?
    @NSManaged public var type: String?
    @NSManaged public var default_name: String?

}

extension Pet : Identifiable {

}
