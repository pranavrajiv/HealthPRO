//
//  WeightInfoViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 5/10/22.
//

import UIKit

class WeightInfoViewController: UIViewController {

    @IBOutlet weak var weightLabelHeading: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.weightLabelHeading.text = "Log Today's Weight"
        self.weightLabel.text = "Enter your current weight"
        self.weightTextField.placeholder = "lbs"
        self.button1.setTitle("Log it", for: .normal)
        self.button2.setTitle("Cancel", for: .normal)
        self.button3.isHidden = true
        
        
        
        self.button1.addTarget(self, action: #selector(button1TouchUpInside), for: .touchUpInside)
        
        
    }

    @objc func button1TouchUpInside() {
        let ac = UIAlertController(title: "Confirmation", message: "Please confirm if you would like to Log int", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            if let weightDouble = Double(self.weightLabel.text!) {
                var historyId:Int64 = -1
                if let largestWeightHistoryId = CoreDataHandler.init().getAllWeightHistory().map({$0.weightHistoryId}).max() {
                    historyId = largestWeightHistoryId
                }
                _  = CoreDataHandler.init().logUserWeightHistory(historyId: historyId + 1, timeStamp: Date(), weight: weightDouble)
            }
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(ac, animated: true)
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
