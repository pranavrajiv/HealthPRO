//
//  User+CoreDataProperties.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 5/3/22.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var birthYear: Int64
    @NSManaged public var contactNumber: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var emailAddress: String?
    @NSManaged public var gender: String?
    @NSManaged public var height: Double
    @NSManaged public var loginId: String?
    @NSManaged public var passcode: String?
    @NSManaged public var weight: Double
    @NSManaged public var foodPreference: String?
    @NSManaged public var activityPreference: String?
    @NSManaged public var userHistoryRelationshipActivity: NSSet?
    @NSManaged public var userHistoryRelationshipFood: NSSet?
    @NSManaged public var userHistoryRelationshipWeight: NSSet?

}

// MARK: Generated accessors for userHistoryRelationshipActivity
extension User {

    @objc(addUserHistoryRelationshipActivityObject:)
    @NSManaged public func addToUserHistoryRelationshipActivity(_ value: ActivityHistory)

    @objc(removeUserHistoryRelationshipActivityObject:)
    @NSManaged public func removeFromUserHistoryRelationshipActivity(_ value: ActivityHistory)

    @objc(addUserHistoryRelationshipActivity:)
    @NSManaged public func addToUserHistoryRelationshipActivity(_ values: NSSet)

    @objc(removeUserHistoryRelationshipActivity:)
    @NSManaged public func removeFromUserHistoryRelationshipActivity(_ values: NSSet)

}

// MARK: Generated accessors for userHistoryRelationshipFood
extension User {

    @objc(addUserHistoryRelationshipFoodObject:)
    @NSManaged public func addToUserHistoryRelationshipFood(_ value: FoodHistory)

    @objc(removeUserHistoryRelationshipFoodObject:)
    @NSManaged public func removeFromUserHistoryRelationshipFood(_ value: FoodHistory)

    @objc(addUserHistoryRelationshipFood:)
    @NSManaged public func addToUserHistoryRelationshipFood(_ values: NSSet)

    @objc(removeUserHistoryRelationshipFood:)
    @NSManaged public func removeFromUserHistoryRelationshipFood(_ values: NSSet)

}

// MARK: Generated accessors for userHistoryRelationshipWeight
extension User {

    @objc(addUserHistoryRelationshipWeightObject:)
    @NSManaged public func addToUserHistoryRelationshipWeight(_ value: WeightHistory)

    @objc(removeUserHistoryRelationshipWeightObject:)
    @NSManaged public func removeFromUserHistoryRelationshipWeight(_ value: WeightHistory)

    @objc(addUserHistoryRelationshipWeight:)
    @NSManaged public func addToUserHistoryRelationshipWeight(_ values: NSSet)

    @objc(removeUserHistoryRelationshipWeight:)
    @NSManaged public func removeFromUserHistoryRelationshipWeight(_ values: NSSet)

}

extension User : Identifiable {

}
