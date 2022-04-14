//
//  CoreDataHandler.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/14/22.
//

import Foundation
import CoreData
import UIKit

@objc public class CoreDataHandler: NSObject {
    var context:NSManagedObjectContext!
    
    public override init() {
        super.init()
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    //check is user already exists in Core Data
    @objc public func doesUserExist(id:String)->Bool {
        do {
            let request = User.fetchRequest()
            let predicate = NSPredicate(format:"loginId == %@",id )
            request.predicate = predicate
            let count = try context.count(for: request)
            if count > 0 {
                return true
            }
        } catch  let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return false
    }
    
    //Add new user to Core Data
    @objc public func addUser(id:String, password:String)->Bool {
        let newUser = User(context: context)
        newUser.loginId = id
        newUser.passcode = password
        do {
            try context.save()
            return true
        } catch let error as NSError {
            print("Could not add user. \(error), \(error.userInfo)")
        }
        return false
    }
    
    // Confirm if login id and password matches
    @objc public func isValidLogin(id:String, passcode:String)->Bool {
        do {
            let request = User.fetchRequest()
            let predicate = NSPredicate(format:"loginId == %@",id )
            request.predicate = predicate
            let usr = try context.fetch(request).first
            if usr?.passcode == passcode {
                return true
            }
        } catch let error as NSError {
            print("Could not check valid login. \(error), \(error.userInfo)")
        }
        return false
    }
}
