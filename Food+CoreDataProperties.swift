//
//  Food+CoreDataProperties.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/28/22.
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

}

extension Food : Identifiable {

}
