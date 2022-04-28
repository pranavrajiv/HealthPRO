//
//  DietViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/11/22.
//

import UIKit

class DietViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var allFood:[Food]!
    var weight: Double!
    var age: Double!
    var height: Double!
    var weight_units: String!
    var height_units: String!
    var sex: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.allFood = CoreDataHandler.init().getAllFood()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allFood.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodTableViewCell", for: indexPath)
        cell.accessibilityLabel = indexPath.row.description
        cell.textLabel?.text = self.allFood[indexPath.row].foodName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark) {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
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
