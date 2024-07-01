//
//  NewPetViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 7/5/2024.
//

import UIKit

/**
 View Controller for creating a new pet
 */

class NewPetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var databaseController: DatabaseProtocol?
    
    var isSaved = false
    var breed: String? {
        didSet {
            petBreedTable.reloadData()
        }
    }
    
    @IBOutlet weak var petBreedTable: UITableView!
    @IBOutlet weak var typeField: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    
    /**
     ViewDidLoad for NewPet View
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController // set database
        
        petBreedTable.delegate = self
        petBreedTable.dataSource = self // table view for breed
        
        if let storedPet = databaseController?.getStoredPet() { // check if user has unfinished new pet
            nameTextField.text = storedPet.name
            
            if storedPet.breed?.count ?? 0 > 0 {
                breed = storedPet.breed
            }
            
            switch storedPet.type {
            case "Dog":
                typeField.selectedSegmentIndex = 0
            case "Cat":
                typeField.selectedSegmentIndex = 1
            case "Other":
                typeField.selectedSegmentIndex = 2
            default:
                typeField.selectedSegmentIndex = 0
            }
            
            // it does have a stored pet so fill in all info
        }
    }
    
    /**
     ViewDidDisappear for New Pet View
     - Parameter animated:
     */
    override func viewDidDisappear(_ animated: Bool) {
        databaseController?.deleteStoredPet() // delete the current stored pet
        
        if !isSaved { // if the pet hasnt been saved then save it
            var type: String
            
            switch typeField.selectedSegmentIndex {
            case 0:
                type = "Dog"
            case 1:
                type = "Cat"
            default:
                type = "Other"
            }
            
            databaseController?.storePet(name: nameTextField.text ?? "", type: type, breed: breed ?? "") // save to coredata
        }
        
        databaseController?.cleanup() // cleanup core data
    }
    
    /**
     Number of rows in section
     - Parameters:
     - tableView:
     - section:
     - Returns:
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    /**
     Format cell
     - Parameters:
     - tableView:
     - indexPath:
     - Returns:
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "breedCell", for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        if let b = breed { // if theres a breed then set the text
            cell.textLabel?.text = b
        } else {
            cell.textLabel?.text = "No breed selected."
        }
        
        return cell
    }
    
    /**
     Prepares for breed selection segue
     - Parameters:
     - segue:
     - sender:
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectBreedSegue" {
            let destination = segue.destination as! PetBreedTableViewController // get destination
            
            var type: String
            
            switch typeField.selectedSegmentIndex {
            case 0:
                type = "Dog"
            case 1:
                type = "Cat"
            default:
                type = "Other"
            }
            destination.petType = type
            destination.newPetDelegate = self  // set the type of pet for the api and set self as delegate of selection
            
            petBreedTable.deselectRow(at: IndexPath(row: 0, section: 0), animated: true) // deselect row
        }
    }

    /**
     When user presses create pet
     - Parameter sender:
     */
    @IBAction func createPetAction(_ sender: Any) {
        if let name = nameTextField.text, let b = breed, !name.isEmpty, !(b == "No breed selected.") { // checking if each field is entered
            
            var type: String
            
            switch typeField.selectedSegmentIndex {
            case 0:
                type = "Dog"
            case 1:
                type = "Cat"
            default:
                type = "Other"
            }
            
            databaseController?.createNewPet(name: name, type: type, breed: b) { result in // add new pet
                if result { // successfully added so segue
                    self.isSaved = true
                    self.navigationController?.popViewController(animated: true)
                    
                } else {
                    self.displayMessage(title: "Error", message: "Failed to add pet")
                }
            }
        } else {
            displayMessage(title: "Error", message: "Please enter a name and breed") // info not entered properly
        }
    }
    
    /**
     When user presses delete
     - Parameter sender:
     */
    @IBAction func deleteAction(_ sender: Any) {
        isSaved = true
        navigationController?.popViewController(animated: true) // segue back to settings
    }
    
    /**
     Displays a message to the screen
     - Parameters:
     - title:
     - message:
     */
    func displayMessage(title: String, message: String) {
                let alertController = UIAlertController(title: title, message: message,
                                                            preferredStyle: .alert)
                    
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
                                                            handler: nil))
                    
                self.present(alertController, animated: true, completion: nil)
        }
    
}
