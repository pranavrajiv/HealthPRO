//
//  Activity+CoreDataProperties.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/28/22.
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

}

extension Activity : Identifiable {

}
