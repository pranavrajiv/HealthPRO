//
//  WeightHistory+CoreDataProperties.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 5/6/22.
//
//

import Foundation
import CoreData


extension WeightHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeightHistory> {
        return NSFetchRequest<WeightHistory>(entityName: "WeightHistory")
    }

    @NSManaged public var timeStamp: Date?
    @NSManaged public var weight: Double
    @NSManaged public var weightHistoryId: Int64
    @NSManaged public var userRelationship: User?

}

extension WeightHistory : Identifiable {

}
