//
//  CoreDataHandler.swift
//  HealthPRO
//
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
    
    @objc public func logToErrorFile(message:String)
    {
        var notificationInfo: [AnyHashable: Any] = [:]
        notificationInfo["message"] = message
        NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
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
            self.logToErrorFile(message: "Could not fetch. \(error), \(error.userInfo)")
        }
        return false
    }

    //Add suggestions to Core Data
    @objc public func addSuggestion(suggestionId:Int64,suggestionTag:String, suggestionText:String,userPreference:String,weather:String,type:String)->Bool {
        
        let newSuggestion = Suggestion(context: context)
        newSuggestion.suggestionId = suggestionId
        newSuggestion.suggestionTag = suggestionTag
        newSuggestion.suggestionText = suggestionText
        newSuggestion.preference = userPreference
        newSuggestion.weather = weather
        newSuggestion.type = type
        do {
            try context.save()
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not add suggestion. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    //Get All Suggestions from Core Data
    @objc public func getAllSuggestions()->[Suggestion] {
        do {
            let request = Suggestion.fetchRequest()

            let matchingSuggestions = try context.fetch(request)
            return matchingSuggestions
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not get suggestions. \(error), \(error.userInfo)")
        }
        return []
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
            self.logToErrorFile(message:"Could not add activity. \(error), \(error.userInfo)")
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
            self.logToErrorFile(message:"Could not add activity. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    //Get all Activities from Core Data
    @objc public func getAllActivities()->[Activity] {
        do {
            let request = Activity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "activityName", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
            let activities = try context.fetch(request)
            return activities
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not get all activities. \(error), \(error.userInfo)")
        }
        return []
    }
    
    //Get filtered Activity from Core Data
    @objc public func getFilteredActivity(text:String)->[Activity] {
        do {
            let request = Activity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "activityName", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
            request.predicate = NSPredicate(format: "activityName CONTAINS[cd] %@", text)
            let foodItems = try context.fetch(request)
            return foodItems
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not get filtered Activity. \(error), \(error.userInfo)")
        }
        return []
    }
    
    //Get Activity for activityId from Core Data
    @objc public func getActivityForId(activityId:Int64)->Activity? {
        do {
            let request = Activity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "activityName", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
            request.predicate = NSPredicate(format: "activityId == %lld", activityId)
            let activityItems = try context.fetch(request)
            return activityItems.first
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not get activity item. \(error), \(error.userInfo)")
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
            self.logToErrorFile(message:"Could not delete activity. \(error), \(error.userInfo)")
        }
        return false
    }
    
    //Log user activity into Core Data
    @objc public func logUserActivity(historyId:Int64,activityId:Int64, timeStamp:Date, duration:Double)->Bool {
        let logActivity = ActivityHistory(context: context)
        logActivity.activityHistoryId = historyId
        logActivity.timeStamp = timeStamp
        logActivity.duration = duration
        logActivity.userRelationship = self.getUser()
        logActivity.activityRelationship = self.getActivityForId(activityId: activityId)
        do {
            try context.save()
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not add food. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    //Get all activity history from Core Data
    @objc public func getAllActivityHistory()->[ActivityHistory] {
        do {
            let request = ActivityHistory.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: true)]
            let activityHistory = try context.fetch(request)
            return activityHistory.filter({$0.userRelationship?.loginId == UserDefaults.standard.string(forKey: "LoginUserName")!})
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not get Activity History. \(error), \(error.userInfo)")
        }
        return []
    }
    
    //Delete Activity History for activityId from Core Data
    @objc public func deleteActivityHistoryForId(activityHistoryId:Int64)->Bool {
        
        do {
            let request = ActivityHistory.fetchRequest()
            request.predicate = NSPredicate(format: "activityHistoryId == %lld", activityHistoryId)
            let activityHistoryItems = try context.fetch(request)
            context.delete(activityHistoryItems.first!)
            try context.save()
            return true
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not delete activity history. \(error), \(error.userInfo)")
        }
        return false
    }
    
    //Update user activity history into Core Data
    @objc public func updateActivityHistory(historyId:Int64,activityId:Int64, timeStamp:Date, duration:Double)->Bool {
        do {
            let request = ActivityHistory.fetchRequest()
            request.predicate = NSPredicate(format: "activityHistoryId == %lld", historyId)
            let activityHistoryItems = try context.fetch(request)
            activityHistoryItems.first!.timeStamp = timeStamp
            activityHistoryItems.first!.duration = duration
            activityHistoryItems.first!.userRelationship = self.getUser()
            activityHistoryItems.first!.activityRelationship = self.getActivityForId(activityId: activityId)
            
            try context.save()
            } catch let error as NSError {
                self.logToErrorFile(message:"Could not update activity history. \(error), \(error.userInfo)")
                return false
            }
            return true
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
            self.logToErrorFile(message:"Could not add food. \(error), \(error.userInfo)")
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
            self.logToErrorFile(message:"Could not update food. \(error), \(error.userInfo)")
        }
        return false
    }
    
    
    //Get filtered Food from Core Data
    @objc public func getFilteredFood(text:String)->[Food] {
        do {
            let request = Food.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "foodName", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
            request.predicate = NSPredicate(format: "foodName CONTAINS[cd] %@", text)
            let foodItems = try context.fetch(request)
            return foodItems
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not get filtered food. \(error), \(error.userInfo)")
        }
        return []
    }
    
    //Get Food for foodId from Core Data
    @objc public func getFoodForId(foodId:Int64)->Food? {
        do {
            let request = Food.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "foodName", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
            request.predicate = NSPredicate(format: "foodId == %lld", foodId)
            let foodItems = try context.fetch(request)
            return foodItems.first
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not get a food item. \(error), \(error.userInfo)")
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
            self.logToErrorFile(message:"Could not delete food. \(error), \(error.userInfo)")
        }
        return false
    }
    
    //Delete Food History for foodId from Core Data
    @objc public func deleteFoodHistoryForId(foodHistoryId:Int64)->Bool {
        
        do {
            let request = FoodHistory.fetchRequest()
            request.predicate = NSPredicate(format: "foodHistoryId == %lld", foodHistoryId)
            let foodHistoryItems = try context.fetch(request)
            context.delete(foodHistoryItems.first!)
            try context.save()
            return true
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not delete food history. \(error), \(error.userInfo)")
        }
        return false
    }
    
    //Update user food history into Core Data
    @objc public func updateFoodHistory(historyId:Int64,foodId:Int64, timeStamp:Date, servingSize:Double)->Bool {
        do {
            let request = FoodHistory.fetchRequest()
            request.predicate = NSPredicate(format: "foodHistoryId == %lld", historyId)
            let foodHistoryItems = try context.fetch(request)
            foodHistoryItems.first!.userRelationship = self.getUser()
            foodHistoryItems.first!.foodRelationship = self.getFoodForId(foodId: foodId)
            foodHistoryItems.first!.timeStamp = timeStamp
            foodHistoryItems.first!.serviceSize = servingSize
            
            try context.save()
            
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not update food history. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    //Log user food into Core Data
    @objc public func logUserFood(historyId:Int64,foodId:Int64, timeStamp:Date, servingSize:Double)->Bool {
        let logFood = FoodHistory(context: context)
        logFood.foodHistoryId = historyId
        logFood.userRelationship = self.getUser()
        logFood.foodRelationship = self.getFoodForId(foodId: foodId)
        logFood.timeStamp = timeStamp
        logFood.serviceSize = servingSize
       
        do {
            try context.save()
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not add food. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    //Get all food history from Core Data
    @objc public func getAllFoodHistory()->[FoodHistory] {
        do {
            let request = FoodHistory.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: true)]
            let foodHistory = try context.fetch(request)
            return foodHistory.filter({$0.userRelationship?.loginId == UserDefaults.standard.string(forKey: "LoginUserName")!})
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not get Food History. \(error), \(error.userInfo)")
        }
        return []
    }
    
    //Get all Food from Core Data
    @objc public func getAllFood()->[Food] {
        do {
            let request = Food.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "foodName", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
            let foodItems = try context.fetch(request)
            return foodItems
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not get all food. \(error), \(error.userInfo)")
        }
        return []
    }
    
    //Delete Weight History for weightHistoryId from Core Data
    @objc public func deleteWeightHistoryForId(weightHistoryId:Int64)->Bool {
        
        do {
            let request = WeightHistory.fetchRequest()
            request.predicate = NSPredicate(format: "weightHistoryId == %lld", weightHistoryId)
            let weightHistoryItems = try context.fetch(request)
            context.delete(weightHistoryItems.first!)
            try context.save()
            return true
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not delete weight history. \(error), \(error.userInfo)")
        }
        return false
    }
    
    
    //Log user weight history into Core Data
    @objc public func logUserWeightHistory(historyId:Int64,timeStamp:Date,weight:Double)->Bool {
        let logWeight = WeightHistory(context: context)
        logWeight.weightHistoryId = historyId
        logWeight.userRelationship = self.getUser()
        logWeight.weight = weight
        logWeight.timeStamp = timeStamp
       
        do {
            try context.save()
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not add user weight. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    //Get all weight history from Core Data
    @objc public func getAllWeightHistory()->[WeightHistory] {
        do {
            let request = WeightHistory.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: true)]
            let weightHistory = try context.fetch(request)
            return weightHistory.filter({$0.userRelationship?.loginId == UserDefaults.standard.string(forKey: "LoginUserName")!})
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not get Weight History. \(error), \(error.userInfo)")
        }
        return []
    }
    
    //Update user Weight history into Core Data
    @objc public func updateWeightHistory(historyId:Int64, timeStamp:Date, weight:Double)->Bool {
        do {
            let request = WeightHistory.fetchRequest()
            request.predicate = NSPredicate(format: "weightHistoryId == %lld", historyId)
            let weightHistoryItems = try context.fetch(request)
            weightHistoryItems.first!.timeStamp = timeStamp
            weightHistoryItems.first!.weight = weight
            weightHistoryItems.first!.userRelationship = self.getUser()

            try context.save()
            } catch let error as NSError {
                self.logToErrorFile(message:"Could not update Weight history. \(error), \(error.userInfo)")
                return false
            }
            return true
    }
    
    //Get user Weight history for a Date from CoreData
    @objc public func doesWeightHistoryExist(forDate:Date)->Bool {
        do {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            
            let request = WeightHistory.fetchRequest()
            let weightHistoryItems = try context.fetch(request)
            let userWeightHistoryItems = weightHistoryItems.filter({$0.userRelationship?.loginId == self.getUser()?.loginId})
            
            return userWeightHistoryItems.contains(where: {formatter.string(from: $0.timeStamp!) == formatter.string(from: forDate)})

            } catch let error as NSError {
                self.logToErrorFile(message:"Could not fetch Weight history. \(error), \(error.userInfo)")
                return false
            }
    }
    
    //Get User from Core Data
    @objc public func getUser()->User? {
        do {
            let id = UserDefaults.standard.string(forKey: "LoginUserName")!
            let request = User.fetchRequest()
            let predicate = NSPredicate(format:"loginId == %@",id )
            request.predicate = predicate
            let usr = try context.fetch(request).first
                return usr
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not fetch user. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    //update app usage time into Core Data
    @objc public func updateUserAppUsageTime(usageTime:Int64)->Bool {
        do {
            let request = User.fetchRequest()
            let id = UserDefaults.standard.string(forKey: "LoginUserName")!
            request.predicate = NSPredicate(format: "loginId == %@",id)
            let currentUser = try context.fetch(request)
            currentUser.first!.usageTImeSeconds = usageTime
            try context.save()
            
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not update app user time. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    //Update user into Core Data
    @objc public func updateUser(weight:Double,height:Double, gender:String, emailAddress:String, contactNumber:String, birthYear:Int,foodPreference:String,activityPreference:String )->Bool {
        do {
            let request = User.fetchRequest()
            let id = UserDefaults.standard.string(forKey: "LoginUserName")!
            request.predicate = NSPredicate(format: "loginId == %@",id)
            let currentUser = try context.fetch(request)
            currentUser.first!.weight = weight
            currentUser.first!.height = height
            currentUser.first!.gender = gender
            currentUser.first!.emailAddress = emailAddress
            currentUser.first!.contactNumber = contactNumber
            currentUser.first!.birthYear = Int64(birthYear)
            currentUser.first!.foodPreference = foodPreference
            currentUser.first!.activityPreference = activityPreference
            try context.save()
            
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not update user. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    //Add new user to Core Data
    @objc public func addUser(id:String, password:String)->Bool {
        let newUser = User(context: context)
        newUser.loginId = id
        newUser.passcode = password
        newUser.dateCreated = Date()
        do {
            try context.save()
            return true
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not add user. \(error), \(error.userInfo)")
        }
        return false
    }
    
    // Confirm if login id and password matches
    @objc public func isValidLogin(id:String, passcode:String)->Bool {
        do {
            let request = User.fetchRequest()
            let predicate = NSPredicate(format:"loginId == %@",id)
            request.predicate = predicate
            let usr = try context.fetch(request).first
            if usr?.passcode == passcode {
                return true
            }
        } catch let error as NSError {
            self.logToErrorFile(message:"Could not check valid login. \(error), \(error.userInfo)")
        }
        return false
    }
}
