//
//  DietViewController.swift
//  HealthPRO
//
//

import UIKit

class DietViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarField: UISearchBar!
    @IBOutlet weak var addNewButton: UIButton!
    var allFood:[Food]!
    var weight: Double!
    var age: Double!
    var height: Double!
    var weight_units: String!
    var height_units: String!
    var sex: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchBarField.searchTextField.text = ""
        self.allFood = CoreDataHandler.init().getAllFood()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBarField.delegate = self
        addNewButton.addTarget(self, action: #selector(addNewButtonTouchUp), for: .touchUpInside)
    }
    
    //new food entry
    @objc private func addNewButtonTouchUp() {
        let secondViewController = ParsedNutritionLabelViewController.init()
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allFood.count
    }
    
    //row at index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodTableViewCell", for: indexPath)
        cell.accessibilityLabel = self.allFood[indexPath.row].foodId.description
        cell.textLabel?.text = self.allFood[indexPath.row].foodName
        return cell
    }
    
    //row selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchBarField.resignFirstResponder()

        let secondViewController = LogNutritionAndActivityViewController.init(id: Int64(Int((tableView.cellForRow(at: indexPath)?.accessibilityLabel)!)!), type: "Food")
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated: true, completion: nil)
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "\n" ){
            searchBar.resignFirstResponder()
        }else if (searchText == "" ){
            self.allFood = CoreDataHandler.init().getAllFood()
        } else {
            self.allFood = CoreDataHandler.init().getFilteredFood(text: searchText)
        }
        self.tableView.reloadData()
    }
          
    //search button clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.searchTextField.text {
            if searchText != "" {
                self.allFood = CoreDataHandler.init().getFilteredFood(text: searchText)
            } else {
                self.allFood = CoreDataHandler.init().getAllFood()
            }
        }
        searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }

}
