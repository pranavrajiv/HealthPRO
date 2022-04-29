//
//  FoodHistory+CoreDataProperties.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/29/22.
//
//

import Foundation
import CoreData


extension FoodHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodHistory> {
        return NSFetchRequest<FoodHistory>(entityName: "FoodHistory")
    }

    @NSManaged public var timeStamp: String?
    @NSManaged public var serviceSize: Double
    @NSManaged public var userRelationship: User?
    @NSManaged public var foodRelationship: Food?

}

extension FoodHistory : Identifiable {

}
