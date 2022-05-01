//
//  FoodHistory+CoreDataProperties.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/30/22.
//
//

import Foundation
import CoreData


extension FoodHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodHistory> {
        return NSFetchRequest<FoodHistory>(entityName: "FoodHistory")
    }

    @NSManaged public var foodHistoryId: Int64
    @NSManaged public var serviceSize: Double
    @NSManaged public var timeStamp: Date?
    @NSManaged public var foodRelationship: Food?
    @NSManaged public var userRelationship: User?

}

extension FoodHistory : Identifiable {

}
