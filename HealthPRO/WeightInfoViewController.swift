//
//  WeightInfoViewController.swift
//  HealthPRO
//
//

import UIKit

protocol WeightDelegate:NSObject {
    func weightInfoUpdated()
}
class WeightInfoViewController: UIViewController {

    @IBOutlet weak var weightLabelHeading: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var dateSelector: UIDatePicker!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    
    var weightHistoryId:Int64 = -1
    var b1Label = ""
    var b2Label = ""
    var b3Label = ""
    var titleLabel = ""
    var titleMsg = ""
    var delegate:WeightDelegate?
    
    //stores the text value for the various buttons in the VC
    convenience init(popOverHeading:String,popOverMessage:String,button1Label:String,button2Label:String,button3Label:String,delegate:WeightDelegate? = nil,weightHistoryId:Int64) {
        self.init()
        self.titleLabel = popOverHeading
        self.b1Label = button1Label
        self.titleMsg = popOverMessage
        self.b2Label = button2Label
        self.b3Label = button3Label
        self.delegate = delegate
        self.weightHistoryId = weightHistoryId
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.weightLabelHeading.text =  self.titleLabel
        self.weightLabel.text =  self.titleMsg
        self.button1.setTitle(self.b1Label, for: .normal)
        self.button2.setTitle(self.b2Label, for: .normal)
        self.button3.setTitle(self.b3Label, for: .normal)
        
        if self.b2Label == "" {
            self.button2.isHidden = true
        }
        
        if self.titleMsg == "" { //happens when updating/deleting an already existing weight entry
            self.weightLabel.isHidden = true
        } else { // date selector not required when logging your daily weights
            self.dateSelector.isHidden = true
        }
        
        //weightHistoryId with any value other than -1 would mean its not a new weight history entry
        if self.weightHistoryId != -1 {
            self.dateSelector.date = (CoreDataHandler.init().getAllWeightHistory().first(where: {$0.weightHistoryId == weightHistoryId})?.timeStamp)!
            self.weightTextField.text = CoreDataHandler.init().getAllWeightHistory().first(where: {$0.weightHistoryId == weightHistoryId})?.weight.description
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.weightTextField.placeholder = "lbs"
        self.dateSelector.maximumDate = Date()
        self.button1.addTarget(self, action: #selector(button1TouchUpInside), for: .touchUpInside)
        self.button2.addTarget(self, action: #selector(button2TouchUpInside), for: .touchUpInside)
        self.button3.addTarget(self, action: #selector(button3TouchUpInside), for: .touchUpInside)
    }

    //log/update button pressed
    @objc func button1TouchUpInside() {
        let ac = UIAlertController(title: "Confirmation", message: "Please confirm if you would like to "+self.b1Label, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            if(self.weightTextField.text != "") {
                if self.weightHistoryId == -1 {
                    self.logWeight()
                } else {
                    self.updateWeight()
                }
                
                //updates user profile with the last logged/updated weight
                if let weightDouble = CoreDataHandler.init().getAllWeightHistory().last?.weight {
                    if let user = CoreDataHandler.init().getUser() {
                        _ = CoreDataHandler.init().updateUser(weight: weightDouble, height: user.height, gender: user.gender!, emailAddress: user.emailAddress!, contactNumber: user.contactNumber!, birthYear: Int(user.birthYear), foodPreference: user.foodPreference!, activityPreference: user.activityPreference!, targetWeight: user.targetWeight)
                    }
                }
            }
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(ac, animated: true)
    }
    
    //Cancel button pressed
    @objc func button3TouchUpInside() {
        let ac = UIAlertController(title: "Confirmation", message: "Please press 'Confirm' if you would like to Cancel", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(ac, animated: true)
    }
    
    //Delete button pressed
    @objc func button2TouchUpInside() {
        let ac = UIAlertController(title: "Confirmation", message: "Please confirm if you would like to Delete", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            _ = CoreDataHandler.init().deleteWeightHistoryForId(weightHistoryId: self.weightHistoryId)
            self.delegate?.weightInfoUpdated()
            
            
            //update user weight to the current last recorded weight incase the last recorded weight was just deleted
            if let weightDouble = CoreDataHandler.init().getAllWeightHistory().last?.weight {
                if let user = CoreDataHandler.init().getUser() {
                    _ = CoreDataHandler.init().updateUser(weight: weightDouble, height: user.height, gender: user.gender!, emailAddress: user.emailAddress!, contactNumber: user.contactNumber!, birthYear: Int(user.birthYear), foodPreference: user.foodPreference!, activityPreference: user.activityPreference!, targetWeight:  user.targetWeight)
                }
            } else { //if there are 0 weight histories then log user weight to 0
                if let user = CoreDataHandler.init().getUser() {
                    _ = CoreDataHandler.init().updateUser(weight: 0.0, height: user.height, gender: user.gender!, emailAddress: user.emailAddress!, contactNumber: user.contactNumber!, birthYear: Int(user.birthYear), foodPreference: user.foodPreference!, activityPreference: user.activityPreference!, targetWeight:  user.targetWeight)
                }
            }
            
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(ac, animated: true)
    }
    
    //updates a weight histroy entry
    @objc private func updateWeight(){
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        if let alreadyExistingHistoryId = CoreDataHandler.init().getAllWeightHistory().first(where: {formatter.string(from: $0.timeStamp!) == formatter.string(from: self.dateSelector.date)})?.weightHistoryId{
            if (alreadyExistingHistoryId != weightHistoryId) {
                _ = CoreDataHandler.init().deleteWeightHistoryForId(weightHistoryId: alreadyExistingHistoryId)
            }
        }
        
        if let weightTextFieldText = self.weightTextField.text, let weightDouble = Double(weightTextFieldText) {
            _  = CoreDataHandler.init().updateWeightHistory(historyId: self.weightHistoryId, timeStamp: self.dateSelector.date, weight: weightDouble)
        }
        self.delegate?.weightInfoUpdated()
    }
    
    //logs a new weight history entry
    @objc private func logWeight() {
        if let weightTextFieldText = self.weightTextField.text, let weightDouble = Double(weightTextFieldText) {
            if(CoreDataHandler.init().doesWeightHistoryExist(forDate: self.dateSelector.date)){
                //Double checks if weight history already exists
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                _  = CoreDataHandler.init().updateWeightHistory(historyId: CoreDataHandler.init().getAllWeightHistory().first(where: {formatter.string(from: $0.timeStamp!) == formatter.string(from: self.dateSelector.date)})!.weightHistoryId, timeStamp: self.dateSelector.date, weight: weightDouble)
            } else {
                // creates new log weight history
                var historyId:Int64 = -1
                if let largestWeightHistoryId = CoreDataHandler.init().getAllWeightHistory().map({$0.weightHistoryId}).max() {
                    historyId = largestWeightHistoryId
                }
                _  = CoreDataHandler.init().logUserWeightHistory(historyId: historyId + 1, timeStamp: self.dateSelector.date, weight: weightDouble)
            }
        
            self.delegate?.weightInfoUpdated()
        }
    }

    //Dismiss the keyboard when touched outside the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

}
