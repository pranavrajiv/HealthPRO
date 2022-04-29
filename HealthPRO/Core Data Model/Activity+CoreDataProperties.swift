//
//  Activity+CoreDataProperties.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/29/22.
//
//

import Foundation
import CoreData


extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity")
    }

    @NSManaged public var activityId: Int64
    @NSManaged public var activityName: String?
    @NSManaged public var caloriesPerHourPerLb: Double
    @NSManaged public var isIndoor: String?
    @NSManaged public var activityHistoryRelationship: NSSet?

}

// MARK: Generated accessors for activityHistoryRelationship
extension Activity {

    @objc(addActivityHistoryRelationshipObject:)
    @NSManaged public func addToActivityHistoryRelationship(_ value: ActivityHistory)

    @objc(removeActivityHistoryRelationshipObject:)
    @NSManaged public func removeFromActivityHistoryRelationship(_ value: ActivityHistory)

    @objc(addActivityHistoryRelationship:)
    @NSManaged public func addToActivityHistoryRelationship(_ values: NSSet)

    @objc(removeActivityHistoryRelationship:)
    @NSManaged public func removeFromActivityHistoryRelationship(_ values: NSSet)

}

extension Activity : Identifiable {

}
