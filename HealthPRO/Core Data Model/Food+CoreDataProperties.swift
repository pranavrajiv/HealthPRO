//
//  Food+CoreDataProperties.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/29/22.
//
//

import Foundation
import CoreData


extension Food {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Food> {
        return NSFetchRequest<Food>(entityName: "Food")
    }

    @NSManaged public var calcium: String?
    @NSManaged public var calories: Int64
    @NSManaged public var carbohydrate: String?
    @NSManaged public var cholesterol: String?
    @NSManaged public var fiber: String?
    @NSManaged public var foodId: Int64
    @NSManaged public var foodName: String?
    @NSManaged public var iron: String?
    @NSManaged public var potassium: String?
    @NSManaged public var protein: String?
    @NSManaged public var sodium: String?
    @NSManaged public var sugars: String?
    @NSManaged public var total_fat: String?
    @NSManaged public var activityHistoryRelationship: NSSet?

}

// MARK: Generated accessors for activityHistoryRelationship
extension Food {

    @objc(addActivityHistoryRelationshipObject:)
    @NSManaged public func addToActivityHistoryRelationship(_ value: FoodHistory)

    @objc(removeActivityHistoryRelationshipObject:)
    @NSManaged public func removeFromActivityHistoryRelationship(_ value: FoodHistory)

    @objc(addActivityHistoryRelationship:)
    @NSManaged public func addToActivityHistoryRelationship(_ values: NSSet)

    @objc(removeActivityHistoryRelationship:)
    @NSManaged public func removeFromActivityHistoryRelationship(_ values: NSSet)

}

extension Food : Identifiable {

}
