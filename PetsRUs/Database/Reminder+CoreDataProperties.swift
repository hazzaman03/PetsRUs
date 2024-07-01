//
//  Reminder+CoreDataProperties.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 5/6/2024.
//
//

import Foundation
import CoreData

/// NSObject for reminder
extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var repeats: String?
    @NSManaged public var title: String?
    @NSManaged public var reminderDate: Date?
    @NSManaged public var default_name: String?

}

extension Reminder : Identifiable {

}
