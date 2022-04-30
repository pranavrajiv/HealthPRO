//
//  ActivityHistory+CoreDataProperties.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/29/22.
//
//

import Foundation
import CoreData


extension ActivityHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActivityHistory> {
        return NSFetchRequest<ActivityHistory>(entityName: "ActivityHistory")
    }

    @NSManaged public var duration: Double
    @NSManaged public var timeStamp: Date?
    @NSManaged public var activityHistoryId: Int64
    @NSManaged public var activityRelationship: Activity?
    @NSManaged public var userRelationship: User?

}

extension ActivityHistory : Identifiable {

}