//
//  User+CoreDataProperties.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/29/22.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var loginId: String?
    @NSManaged public var passcode: String?
    @NSManaged public var userHistoryRelationshipActivity: NSSet?
    @NSManaged public var userHistoryRelationshipFood: NSSet?

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

extension User : Identifiable {

}
