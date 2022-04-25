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
    
    //Add new Food to Core Data
    @objc public func addFood(foodId:Int64, foodName:String, calories:Int64, total_fat:String,cholesterol:String,sodium:String,calcium:String,iron:String,potassium:String,protein:String,carbohydrate:String,sugars:String,fiber:String)->Bool {
        let newFood = Food(context: context)
        newFood.foodID = foodId
        newFood.foodName = foodName
        newFood.calories = calories
        newFood.total_fat = total_fat
        newFood.cholesterol = cholesterol
        newFood.sodium = sodium
        newFood.calcium = calcium
        newFood.iron = iron
        newFood.potassium = newFood.potassium
        newFood.protein = newFood.protein
        newFood.carbohydrate = newFood.carbohydrate
        newFood.sugars = newFood.sugars
        newFood.fiber = newFood.fiber

        do {
            try context.save()
            return true
        } catch let error as NSError {
            print("Could not add food. \(error), \(error.userInfo)")
        }
        return false
    }
    
    //Get all Food from Core Data
    @objc public func getAllFood() {
        do {
            let request = Food.fetchRequest()
            //let predicate = NSPredicate(format:"loginId == %@",id )
            //request.predicate = predicate
            let foodItems = try context.fetch(request)//.first
            
            for foodItem in foodItems {
                print(foodItem.foodID)
                print(foodItem.foodName)
                print(foodItem.carbohydrate)
                print("\n\n")
            }
            
        } catch let error as NSError {
            print("Could not check valid login. \(error), \(error.userInfo)")
        }
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
