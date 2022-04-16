//
//  DietViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/11/22.
//

import UIKit

class DietViewController: UIViewController {
    var weight: Double!
    var age: Double!
    var height: Double!
    var weight_units: String!
    var height_units: String!
    var sex: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // TODO these variables should be pulled from the UI on the first
        // run, or the database on subsequent runs
        self.weight = 140
        self.age = 29
        self.height = 69
        self.weight_units = "lbs"
        self.height_units = "in"
        self.sex = "Male"
        standardize_height_units()
        standardize_weight_units()
        let bmr = calculate_bmr()
        print(bmr)
    }
    
    func standardize_weight_units() {
        // Convert all weights to kg for further processing
        if self.weight_units == "kg" {
                return
        // Convert lbs to kg, rounding up as necessary
        } else if self.weight_units == "lbs" {
            self.weight = round(self.weight * 0.453592)
        // Convert stone to kg, rounding up as necessary
        } else {
            self.weight = round(self.weight * 6.35029)
        }
    }
    
    func standardize_height_units() {
        // Ensures that all heights are converted to cm for further processing
        // If units are already in centimeters no conversion needed
        if self.height_units == "cm" {
            return
        // Convert inches to centimeters, rounding up as necessary
        } else {
            self.height = round(height * 2.54)
        }
    }
    
    func calculate_bmr() -> Int {
        // Calculates basal metabolic rate using the Mifflin St Jeor equation
        let weight_factor = 10.0 * self.weight
        let height_factor = 6.25 * self.height
        let age_factor = 5.0 * self.age
        let sex_factor: Double
        if sex == "Female" {
            sex_factor = -161.0
        } else {
            sex_factor = 5.0
        }
        let bmr = Int(weight_factor + height_factor - age_factor + sex_factor)
        return bmr
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
