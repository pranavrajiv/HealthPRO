//
//  DietViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/11/22.
//

import UIKit

class DietViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var weight = 130.00
        let age = 30.00
        var height = 69.00
        let weight_units = "lbs"
        let height_units = "in"
        let sex = "Male"
        height = standardize_height_units(height: height, height_units: height_units)
        weight = standardize_weight_units(weight: weight, weight_units: weight_units)
        let bmr = calculate_bmr(weight: weight, height: height, age:age, sex:sex)
        print(bmr)
    }
    
    func standardize_weight_units(weight: Double, weight_units: String) -> Double {
        // Convert all weights to kg for further processing
        var new_weight: Double
        if weight_units == "kg" {
                return weight
        // Convert lbs to kg, rounding up as necessary
        } else if weight_units == "lbs" {
            new_weight = round(weight * 0.453592)
        // Convert stone to kg, rounding up as necessary
        } else {
            new_weight = round(weight * 6.35029)
        }
        return new_weight
    }
    
    func standardize_height_units(height: Double, height_units: String) -> Double {
        // Ensures that all heights are converted to cm for further processing
        var new_height: Double
        // If units are already in centimeters no conversion needed
        if height_units == "cm" {
            return height
        // Convert inches to centimeters, rounding up as necessary
        } else {
        new_height = round(height * 2.54)
        }
        return new_height
    }
    
    func calculate_bmr(weight: Double, height: Double, age: Double, sex: String) -> Double {
        // Calculates basal metabolic rate using the Mifflin St Jeor equation
        let weight_factor = 10.0 * weight
        let height_factor = 6.25 * height
        let age_factor = 5.0 * age
        let sex_factor: Double
        if sex == "Female" {
            sex_factor = -161.0
        } else {
            sex_factor = 5.0
        }
        let bmr = weight_factor + height_factor - age_factor + sex_factor
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
