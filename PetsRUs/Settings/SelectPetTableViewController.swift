//
//  SelectPetTableViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 7/5/2024.
//

import UIKit

/**
 View Controller for Select Pet
 */
class SelectPetTableViewController: UITableViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    var pets: [PetClass] = []
    
    /**
     ViewDidLoad for Select Pet View
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController // setting database
        
        pets = databaseController?.getAllPets() ?? [] // get all the pets for current user
    }
    
    ///
    /// - Parameter tableView:
    /// - Returns:
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    ///
    /// - Parameters:
    ///   - tableView:
    ///   - section:
    /// - Returns:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pets.isEmpty {
            return 1 // only show no pets
        }
        
        return pets.count
    }
    
    /**
     Format Cell
     - Parameters:
     - tableView:
     - indexPath:
     - Returns:
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if pets.isEmpty { // no pets just show no pets message
            let cell = tableView.dequeueReusableCell(withIdentifier: "petCell", for: indexPath)
            cell.textLabel?.text = "No pets to select. Please add a pet"
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "petCell", for: indexPath)
        
        cell.textLabel?.text = pets[indexPath.row].name // put pets name on cell
        
        return cell
    }
    
    /**
     User selects pet
     - Parameters:
     - tableView:
     - indexPath:  
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !pets.isEmpty { // if there are pets then we can select that one and segue back to app
            databaseController?.setPet(pet: pets[indexPath.row])
            self.navigationController?.popViewController(animated: true)
        }
    }
}
