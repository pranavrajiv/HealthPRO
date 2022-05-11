//
//  UserHistoryViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/29/22.
//

import UIKit

class UserHistoryViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,WeightDelegate  {
    @IBOutlet weak var logWeight: UIButton!
    @IBOutlet weak var showAllSwitch: UISwitch!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var userActivityHistory:[ActivityHistory]!
    var userFoodHistory:[FoodHistory]!
    var userWeightHistory:[WeightHistory]!
    var weightDatePicker:UIDatePicker!
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            if self.showAllSwitch.isOn {
                self.userActivityHistory = CoreDataHandler.init().getAllActivityHistory()
                self.userFoodHistory = CoreDataHandler.init().getAllFoodHistory()
                self.userWeightHistory = CoreDataHandler.init().getAllWeightHistory()
            } else {
                self.datePickerChanged()
            }
            self.historyTableView.reloadData()
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.logWeight.addTarget(self, action: #selector(logUserWeight), for: .touchUpInside)
            self.dismissButton.addTarget(self, action: #selector(dismissButtonTouchUp), for: .touchUpInside)
            self.segmentedControl.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for: UIControl.Event.valueChanged)
            self.datePicker.maximumDate = Date()
            self.datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
            self.showAllSwitch.addTarget(self, action: #selector(showAllSwitchChanged), for: .valueChanged)
            self.showAllSwitch.isOn = false
            self.logWeight.isHidden = true
            
            self.historyTableView.delegate = self
            self.historyTableView.dataSource = self
            // Do any additional setup after loading the view.
        }
    
    
    @objc func weightInfoUpdated() {
        self.showAllSwitchChanged()
    }
    
//    @objc private func logWeight(weight:String){
//        if let weightDouble = Double(weight) {
//            if(CoreDataHandler.init().doesWeightHistoryExist(forDate: self.weightDatePicker.date)){
//                
//                let formatter = DateFormatter()
//                formatter.dateStyle = .short
//                _  = CoreDataHandler.init().updateWeightHistory(historyId: CoreDataHandler.init().getAllWeightHistory().first(where: {formatter.string(from: $0.timeStamp!) == formatter.string(from: self.weightDatePicker.date)})!.weightHistoryId, timeStamp: self.weightDatePicker.date, weight: weightDouble)
//            } else {
//                var historyId:Int64 = -1
//                if let largestWeightHistoryId = CoreDataHandler.init().getAllWeightHistory().map({$0.weightHistoryId}).max() {
//                    historyId = largestWeightHistoryId
//                }
//                _  = CoreDataHandler.init().logUserWeightHistory(historyId: historyId + 1, timeStamp: self.weightDatePicker.date, weight: weightDouble)
//            }
//        }
//        self.showAllSwitchChanged()
//    }
    
    
    
    
    @objc private func logUserWeight(){
        let controller = WeightInfoViewController.init(popOverHeading: "Log Weight History", button1Label: "Log", button2Label: "", button3Label: "Cancel",delegate: self)
        controller.modalPresentationStyle = .popover
        
        if let popover = controller.popoverPresentationController {
            popover.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
           
            popover.sourceView = self.view

           // the position of the popover where it's showed
            popover.sourceRect = CGRect(x: 20, y: 400, width: 0, height: 0)

           // the size you want to display
            controller.preferredContentSize = CGSize(width: self.view.frame.width - 40, height: 200)
            popover.delegate = self
        }
        self.present(controller, animated: true, completion: {self.showAllSwitchChanged()})
    }
        
        
    
    
    
    
    
//    @objc private func logUserWeight() {
//        let ac = UIAlertController(title: "Log Weight History", message: "\n\n", preferredStyle: .alert)
//        ac.addTextField { (textField) in
//            textField.placeholder = "weight (lbs)"
//            textField.textAlignment = .center
//            textField.isEnabled = false
//        }
//
//        ac.addAction(UIAlertAction(title: "Log", style: .default, handler: { action in
//            if let weightText = ac.textFields?.first?.text {
//                if weightText != "" {
//                    self.logWeight(weight:weightText)
//                }
//            }
//        }))
//
//        self.weightDatePicker = UIDatePicker()
//        self.weightDatePicker.maximumDate = Date()
//        weightDatePicker.preferredDatePickerStyle = .compact
//        weightDatePicker.datePickerMode = .date
//        weightDatePicker.frame = CGRect(x: weightDatePicker.frame.origin.x - 15, y: 50, width: weightDatePicker.frame.size.width, height: weightDatePicker.frame.size.height)
//
//        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        ac.view.addSubview(self.weightDatePicker)
//        self.present(ac, animated: true, completion: {
//            if let getTextfield  = ac.textFields?.first{
//                    getTextfield.resignFirstResponder()
//                    getTextfield.isEnabled = true
//            }
//        })
//    }
    
//    @objc private func updateWeight(weight:String,weightHistoryId:Int64){
//        if let weightDouble = Double(weight) {
//            _  = CoreDataHandler.init().updateWeightHistory(historyId: CoreDataHandler.init().getAllWeightHistory().first(where: {$0.weightHistoryId == weightHistoryId})!.weightHistoryId, timeStamp: self.weightDatePicker.date, weight: weightDouble)
//        }
//        self.showAllSwitchChanged()
//    }
//    
    
    @objc private func updateUserWeight(weightHistoryId:Int64) {
        
        let controller = WeightInfoViewController.init(popOverHeading: "Update Weight History", button1Label: "Update", button2Label: "Delete", button3Label: "Cancel",delegate: self,weightHistoryId: weightHistoryId)
        controller.modalPresentationStyle = .popover
        
        if let popover = controller.popoverPresentationController {
            popover.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
           
            popover.sourceView = self.view

           // the position of the popover where it's showed
            popover.sourceRect = CGRect(x: 20, y: 400, width: 0, height: 0)

           // the size you want to display
            controller.preferredContentSize = CGSize(width: self.view.frame.width - 40, height: 200)
            popover.delegate = self
        }
        self.present(controller, animated: true, completion: {self.showAllSwitchChanged()})
        
        
        
        
        
        
//        let ac = UIAlertController(title: "Update Weight History", message: "\n\n", preferredStyle: .alert)
//        ac.addTextField { (textField) in
//            textField.placeholder = "weight (lbs)"
//            textField.textAlignment = .center
//            textField.isEnabled = false
//            textField.text = CoreDataHandler.init().getAllWeightHistory().first(where: {$0.weightHistoryId == weightHistoryId})?.weight.description
//        }
//
//        //TODO  weightText != "" IIIIIIIIIIMMMMMPOOOORRRTTTTAAAANNNTTTTTT
//        ac.addAction(UIAlertAction(title: "Update", style: .default, handler: { action in
//            if let weightText = ac.textFields?.first?.text {
//                if weightText != "" {
//
//
//                    //self.updateWeight(weight:weightText, weightHistoryId:weightHistoryId)
//                }
//            }
//        }))
//
//        self.weightDatePicker = UIDatePicker()
//        self.weightDatePicker.maximumDate = Date()
//
//        self.weightDatePicker.preferredDatePickerStyle = .compact
//        self.weightDatePicker.datePickerMode = .date
//        self.weightDatePicker.frame = CGRect(x: weightDatePicker.frame.origin.x - 15, y: 50, width: weightDatePicker.frame.size.width, height: weightDatePicker.frame.size.height)
//
//        ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
//            _ = CoreDataHandler.init().deleteWeightHistoryForId(weightHistoryId: weightHistoryId)
//            self.showAllSwitchChanged()
//        }))
//
//        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        ac.view.addSubview(self.weightDatePicker)
//        self.present(ac, animated: true, completion: {
//            if let getTextfield  = ac.textFields?.first{
//                    getTextfield.resignFirstResponder()
//                    getTextfield.isEnabled = true
//            }
//        })
    }

        @objc private func dismissButtonTouchUp() {
            self.dismiss(animated: true)
        }
    
        @objc private func showAllSwitchChanged() {
            if self.showAllSwitch.isOn {
                self.datePicker.isHidden = true
                self.userActivityHistory = CoreDataHandler.init().getAllActivityHistory()
                self.userFoodHistory = CoreDataHandler.init().getAllFoodHistory()
                self.userWeightHistory = CoreDataHandler.init().getAllWeightHistory()
            } else {
                self.datePicker.isHidden = false
                self.datePickerChanged()
            }
            self.historyTableView.reloadData()
        }
    
        @objc private func datePickerChanged() {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            self.userActivityHistory = CoreDataHandler.init().getAllActivityHistory().filter({formatter.string(from: self.datePicker.date) == formatter.string(from: $0.timeStamp!)})
            self.userFoodHistory = CoreDataHandler.init().getAllFoodHistory().filter({formatter.string(from: self.datePicker.date) == formatter.string(from: $0.timeStamp!)})
            self.userWeightHistory = CoreDataHandler.init().getAllWeightHistory().filter({formatter.string(from: self.datePicker.date) == formatter.string(from: $0.timeStamp!)})
            self.historyTableView.reloadData()
        }
    
        @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
            self.logWeight.isHidden = true
            if self.segmentedControl.selectedSegmentIndex == 2 {
                self.logWeight.isHidden = false
            }
            self.historyTableView.reloadData()
        }
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if self.segmentedControl.selectedSegmentIndex == 0 {
                return self.userFoodHistory.count
            } else if self.segmentedControl.selectedSegmentIndex == 1 {
                return self.userActivityHistory.count
            }
            return self.self.userWeightHistory.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyTableViewCell", for: indexPath)
            let uiLabels = cell.contentView.subviews.compactMap({ $0 as? UILabel })
                
                for cellLabel in uiLabels {
                    if self.segmentedControl.selectedSegmentIndex == 0 {
                        if cellLabel.accessibilityLabel == "historyDateAccessibilityLabel" {
                            cellLabel.text = formatter.string(from: self.userFoodHistory[indexPath.row].timeStamp!)
                            for constraints in cellLabel.constraints {
                                if constraints.identifier == "dateCreatedConstraint" {
                                    if !self.showAllSwitch.isOn {
                                        constraints.constant = 0
                                    } else {
                                        constraints.constant = 65
                                    }
                                }
                            }
                        } else {
                            cell.accessibilityLabel = self.userFoodHistory[indexPath.row].foodHistoryId.description
                            cellLabel.text = self.userFoodHistory[indexPath.row].foodRelationship?.foodName
                        }
                    } else if self.segmentedControl.selectedSegmentIndex == 1  {
                        if cellLabel.accessibilityLabel == "historyDateAccessibilityLabel" {
                            cellLabel.text = formatter.string(from: self.userActivityHistory[indexPath.row].timeStamp!)
                            for constraints in cellLabel.constraints {
                                if constraints.identifier == "dateCreatedConstraint" {
                                    if !self.showAllSwitch.isOn {
                                        constraints.constant = 0
                                    } else {
                                        constraints.constant = 65
                                    }
                                }
                            }
                        } else {
                            cell.accessibilityLabel = self.userActivityHistory[indexPath.row].activityHistoryId.description
                            cellLabel.text = self.userActivityHistory[indexPath.row].activityRelationship?.activityName
                        }
                    } else {
                        if cellLabel.accessibilityLabel == "historyDateAccessibilityLabel" {
                            cellLabel.text = formatter.string(from: self.userWeightHistory[indexPath.row].timeStamp!)
                            for constraints in cellLabel.constraints {
                                if constraints.identifier == "dateCreatedConstraint" {
                                    if !self.showAllSwitch.isOn {
                                        constraints.constant = 0
                                    } else {
                                        constraints.constant = 65
                                    }
                                }
                            }
                        } else {
                            cell.accessibilityLabel = self.userWeightHistory[indexPath.row].weightHistoryId.description
                            cellLabel.text = self.userWeightHistory[indexPath.row].weight.description + " lbs"
                        }
                    }
                }
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if self.segmentedControl.selectedSegmentIndex == 2 {
               self.updateUserWeight(weightHistoryId: Int64(Int((tableView.cellForRow(at: indexPath)?.accessibilityLabel)!)!))
            } else {
                var secondViewController = LogNutritionAndActivityViewController.init(historyId: Int64(Int((tableView.cellForRow(at: indexPath)?.accessibilityLabel)!)!), type: "Activity")
                if self.segmentedControl.selectedSegmentIndex == 0 {
                    secondViewController = LogNutritionAndActivityViewController.init(historyId: Int64(Int((tableView.cellForRow(at: indexPath)?.accessibilityLabel)!)!), type: "Food")
                }
                secondViewController.modalPresentationStyle = .fullScreen
                self.present(secondViewController, animated: true, completion: nil)
            }
        }

    }


extension UserHistoryViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {

    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

