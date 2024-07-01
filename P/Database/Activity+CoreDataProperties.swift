//
//  Activity+CoreDataProperties.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 5/6/2024.
//
//

import Foundation
import CoreData

/// NSObject for activity
extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity")
    }

    @NSManaged public var category: String?
    @NSManaged public var title: String?
    @NSManaged public var notes: String?
    @NSManaged public var dateCompleted: Date?
    @NSManaged public var default_name: String?

}

extension Activity : Identifiable {

}
