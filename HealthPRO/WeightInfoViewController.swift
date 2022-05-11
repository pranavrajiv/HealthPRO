//
//  WeightInfoViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 5/10/22.
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
    
    convenience init(popOverHeading:String,popOverMessage:String,button1Label:String,button3Label:String) {
        self.init()
        self.titleMsg = popOverMessage
        self.titleLabel = popOverHeading
        self.b1Label = button1Label
        self.b3Label = button3Label
    }
    
    convenience init(popOverHeading:String,button1Label:String,button3Label:String,delegate:WeightDelegate) {
        self.init()
        self.titleLabel = popOverHeading
        self.b1Label = button1Label
        self.b3Label = button3Label
        self.delegate = delegate
    }
    
    convenience init(popOverHeading:String,button1Label:String,button2Label:String,button3Label:String,delegate:WeightDelegate,weightHistoryId:Int64) {
        self.init()
        self.titleLabel = popOverHeading
        self.b1Label = button1Label
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
        
        if self.titleMsg == "" {
            self.weightLabel.isHidden = true
        } else {
            self.dateSelector.isHidden = true
        }
        
        
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
            }
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(ac, animated: true)
    }
    
    @objc func button3TouchUpInside() {
        let ac = UIAlertController(title: "Confirmation", message: "Please press 'Confirm' if you would like to Cancel", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(ac, animated: true)
    }
    
    
    @objc func button2TouchUpInside() {
        let ac = UIAlertController(title: "Confirmation", message: "Please confirm if you would like to Delete", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            _ = CoreDataHandler.init().deleteWeightHistoryForId(weightHistoryId: self.weightHistoryId)
            self.delegate?.weightInfoUpdated()
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(ac, animated: true)
    }
    
    
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
    
    @objc private func logWeight(){
        if let weightTextFieldText = self.weightTextField.text, let weightDouble = Double(weightTextFieldText) {
            if(CoreDataHandler.init().doesWeightHistoryExist(forDate: self.dateSelector.date)){
                
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                _  = CoreDataHandler.init().updateWeightHistory(historyId: CoreDataHandler.init().getAllWeightHistory().first(where: {formatter.string(from: $0.timeStamp!) == formatter.string(from: self.dateSelector.date)})!.weightHistoryId, timeStamp: self.dateSelector.date, weight: weightDouble)
            } else {
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
