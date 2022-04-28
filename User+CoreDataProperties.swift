//
//  User+CoreDataProperties.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/28/22.
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

}

extension User : Identifiable {

}
