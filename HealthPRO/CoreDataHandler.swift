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
   
    //Add new activity to Core Data
    @objc public func addActivity(activityId:Int64,activityName:String, caloriesPerHourPerLb:Double,isIndoor:String)->Bool {
        
        let newActivity = Activity(context: context)
        newActivity.activityId = activityId
        newActivity.activityName = activityName
        newActivity.caloriesPerHourPerLb = caloriesPerHourPerLb
        newActivity.isIndoor = isIndoor
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not add activity. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    //Update Activity in Core Data
    @objc public func updateActivity(activityId:Int64,activityName:String, caloriesPerHourPerLb:Double,isIndoor:String)->Bool {
        do {
            let request = Activity.fetchRequest()
            request.predicate = NSPredicate(format: "activityId == %lld", activityId)
            let activityItems = try context.fetch(request)
            activityItems.first!.activityName = activityName
            activityItems.first!.caloriesPerHourPerLb = caloriesPerHourPerLb
            activityItems.first!.isIndoor = isIndoor
            try context.save()
            
        } catch let error as NSError {
            print("Could not add activity. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    //Get all Activities from Core Data
    @objc public func getAllActivities()->[Activity] {
        do {
            let request = Activity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "activityName", ascending: true)]
            let activities = try context.fetch(request)
            return activities
        } catch let error as NSError {
            print("Could not get all activities. \(error), \(error.userInfo)")
        }
        return []
    }
    
    //Get filtered Activity from Core Data
    @objc public func getFilteredActivity(text:String)->[Activity] {
        do {
            let request = Activity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "activityName", ascending: true)]
            request.predicate = NSPredicate(format: "activityName CONTAINS[cd] %@", text)
            let foodItems = try context.fetch(request)
            return foodItems
        } catch let error as NSError {
            print("Could not get filtered Activity. \(error), \(error.userInfo)")
        }
        return []
    }
    
    //Get Activity for activityId from Core Data
    @objc public func getActivityForId(activityId:Int64)->Activity? {
        do {
            let request = Activity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "activityName", ascending: true)]
            request.predicate = NSPredicate(format: "activityId == %lld", activityId)
            let activityItems = try context.fetch(request)
            return activityItems.first
        } catch let error as NSError {
            print("Could not get activity item. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    //Delete Activity for activityId from Core Data
    @objc public func deleteActivityForId(activityId:Int64)->Bool {
        
        do {
            let request = Activity.fetchRequest()
            request.predicate = NSPredicate(format: "activityId == %lld", activityId)
            let activityItems = try context.fetch(request)
            context.delete(activityItems.first!)
            try context.save()
            return true
        } catch let error as NSError {
            print("Could not delete activity. \(error), \(error.userInfo)")
        }
        return false
    }
    
    //Log user activity into Core Data
    @objc public func logUserActivity(activityId:Int64, timeStamp:String, duration:Double)->Bool {
        let logActivity = ActivityHistory(context: context)
        logActivity.timeStamp = timeStamp
        logActivity.duration = duration
        logActivity.userRelationship = self.getUser(id: UserDefaults.standard.string(forKey: "LoginUserName")!)
        logActivity.activityRelationship = self.getActivityForId(activityId: activityId)
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not add food. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    //Get all activity history from Core Data
    @objc public func getAllActivityHistory()->[ActivityHistory] {
        do {
            let request = ActivityHistory.fetchRequest()
            let activityHistory = try context.fetch(request)
            return activityHistory
        } catch let error as NSError {
            print("Could not get Activity History. \(error), \(error.userInfo)")
        }
        return []
    }
    
    
    //Update Food in Core Data
    @objc public func addFood(foodId:Int64,foodName:String, calories:Int64, total_fat:String,cholesterol:String,sodium:String,calcium:String,iron:String,potassium:String, protein:String,carbohydrate:String,sugars:String,fiber:String)->Bool {
        let newFood = Food(context: context)
        newFood.foodId = foodId
        newFood.foodName = foodName
        newFood.calories = calories
        newFood.total_fat = total_fat
        newFood.cholesterol = cholesterol
        newFood.sodium = sodium
        newFood.calcium = calcium
        newFood.iron = iron
        newFood.potassium = potassium
        newFood.protein = protein
        newFood.carbohydrate = carbohydrate
        newFood.sugars = sugars
        newFood.fiber = fiber
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not add food. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    //Update Food in Core Data
    @objc public func updateFood(foodId:Int64,foodName:String, calories:Int64, total_fat:String,cholesterol:String,sodium:String,calcium:String,iron:String,potassium:String, protein:String,carbohydrate:String,sugars:String,fiber:String)->Bool {
        
       do {
            let request = Food.fetchRequest()
            request.predicate = NSPredicate(format: "foodId == %lld", foodId)
            let foodItems = try context.fetch(request)
           foodItems.first!.foodName = foodName
           foodItems.first!.calories = calories
           foodItems.first!.total_fat = total_fat
           foodItems.first!.cholesterol = cholesterol
           foodItems.first!.sodium = sodium
           foodItems.first!.calcium = calcium
           foodItems.first!.iron = iron
           foodItems.first!.potassium = potassium
           foodItems.first!.protein = protein
           foodItems.first!.carbohydrate = carbohydrate
           foodItems.first!.sugars = sugars
           foodItems.first!.fiber = fiber

           try context.save()
            return true
        } catch let error as NSError {
            print("Could not update food. \(error), \(error.userInfo)")
        }
        return false
    }
    
    
    //Get filtered Food from Core Data
    @objc public func getFilteredFood(text:String)->[Food] {
        do {
            let request = Food.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "foodName", ascending: true)]
            request.predicate = NSPredicate(format: "foodName CONTAINS[cd] %@", text)
            let foodItems = try context.fetch(request)
            return foodItems
        } catch let error as NSError {
            print("Could not get filtered food. \(error), \(error.userInfo)")
        }
        return []
    }
    
    //Get Food for foodId from Core Data
    @objc public func getFoodForId(foodId:Int64)->Food? {
        do {
            let request = Food.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "foodName", ascending: true)]
            request.predicate = NSPredicate(format: "foodId == %lld", foodId)
            let foodItems = try context.fetch(request)
            return foodItems.first
        } catch let error as NSError {
            print("Could not get a food item. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    //Delete Food for foodId from Core Data
    @objc public func deleteFoodForId(foodId:Int64)->Bool {
        
        do {
            let request = Food.fetchRequest()
            request.predicate = NSPredicate(format: "foodId == %lld", foodId)
            let foodItems = try context.fetch(request)
            context.delete(foodItems.first!)
            try context.save()
            return true
        } catch let error as NSError {
            print("Could not delete food. \(error), \(error.userInfo)")
        }
        return false
    }
    
    //Log user food into Core Data
    @objc public func logUserFood(foodId:Int64, timeStamp:String, servingSize:Double)->Bool {
        let logFood = FoodHistory(context: context)
        logFood.userRelationship = self.getUser(id: UserDefaults.standard.string(forKey: "LoginUserName")!)
        logFood.foodRelationship = self.getFoodForId(foodId: foodId)
        logFood.timeStamp = timeStamp
        logFood.serviceSize = servingSize
       
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not add food. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    //Get all food history from Core Data
    @objc public func getAllFoodHistory()->[FoodHistory] {
        do {
            let request = FoodHistory.fetchRequest()
            let foodHistory = try context.fetch(request)
            return foodHistory
        } catch let error as NSError {
            print("Could not get Food History. \(error), \(error.userInfo)")
        }
        return []
    }
    
    //Get all Food from Core Data
    @objc public func getAllFood()->[Food] {
        do {
            let request = Food.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "foodName", ascending: true)]
            let foodItems = try context.fetch(request)
            return foodItems
        } catch let error as NSError {
            print("Could not get all food. \(error), \(error.userInfo)")
        }
        return []
    }
    
    //Get User from Core Data
    @objc public func getUser(id:String)->User? {
        do {
            let request = User.fetchRequest()
            let predicate = NSPredicate(format:"loginId == %@",id )
            request.predicate = predicate
            let usr = try context.fetch(request).first
                return usr
        } catch let error as NSError {
            print("Could not fetch user. \(error), \(error.userInfo)")
        }
        return nil
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
