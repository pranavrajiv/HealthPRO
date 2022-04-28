//
//  ExerciseViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/11/22.
//

import UIKit

class ExerciseViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate  {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarField: UISearchBar!
    @IBOutlet weak var addNewButton: UIButton!
    var allExercise:[Activity]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchBarField.searchTextField.text = ""
        self.allExercise = CoreDataHandler.init().getAllActivities()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBarField.delegate = self
        addNewButton.addTarget(self, action: #selector(addNewButtonTouchUp), for: .touchUpInside)
    }
    
    @objc private func addNewButtonTouchUp() {
        let secondViewController = ActivityInfoViewController.init()
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allExercise.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseTableViewCell", for: indexPath)
        cell.accessibilityLabel = self.allExercise[indexPath.row].activityId.description
        cell.textLabel?.text = self.allExercise[indexPath.row].activityName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchBarField.resignFirstResponder()

        let secondViewController = ActivityInfoViewController.init(activityId: Int64(Int((tableView.cellForRow(at: indexPath)?.accessibilityLabel)!)!))
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated: true, completion: nil)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "\n" ){
            searchBar.resignFirstResponder()
        }else if (searchText == "" ){
            self.allExercise = CoreDataHandler.init().getAllActivities()
        } else {
            self.allExercise = CoreDataHandler.init().getFilteredActivity(text: searchText)
        }
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.searchTextField.text {
            if searchText != "" {
                self.allExercise = CoreDataHandler.init().getFilteredActivity(text: searchText)
            } else {
                self.allExercise = CoreDataHandler.init().getAllActivities()
            }
        }
        searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
    
}
