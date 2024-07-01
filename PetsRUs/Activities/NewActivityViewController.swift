//
//  NewActivityViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 9/5/2024.
//

import UIKit
import FirebaseFirestore

/// View Controller for New Activity
class NewActivityViewController: UIViewController {

    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateCompletedPicker: UIDatePicker!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var notesTextField: UITextField!
    
    var isSaved = false
    
    /// ViewDidLoad for new activity
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController // setting database
        
        if let storedActivity = databaseController?.getStoredActivity() { // if theres a stored activity then get this
            titleTextField.text = storedActivity.title
            notesTextField.text = storedActivity.notes
            dateCompletedPicker.date = storedActivity.dateCompleted ?? Date() // change inputs to reflect stored activity
            
            switch storedActivity.category {
            case "Food":
                categorySegmentedControl.selectedSegmentIndex = 0
            case "Exercise":
                categorySegmentedControl.selectedSegmentIndex = 1
            case "Toilet":
                categorySegmentedControl.selectedSegmentIndex = 2
            case "Groom":
                categorySegmentedControl.selectedSegmentIndex = 3
            case "Other":
                categorySegmentedControl.selectedSegmentIndex = 4
            default:
                categorySegmentedControl.selectedSegmentIndex = 0
            } // setting category
        }
        
    }
    
    ///
    /// - Parameter animated:
    override func viewDidDisappear(_ animated: Bool) {
        databaseController?.deleteStoredActivity() // delete the stored activity
        
        if !isSaved { // need to store the activity
            var category: String
            
            switch categorySegmentedControl.selectedSegmentIndex {
            case 0:
                category = "Food"
            case 1:
                category = "Exercise"
            case 2:
                category = "Toilet"
            case 3:
                category = "Groom"
            default:
                category = "Other"
            } // get the category string
            
            databaseController?.storeActivity(title: titleTextField.text ?? "", notes: notesTextField.text ?? "", category: category, dateCompleted: dateCompletedPicker.date) // store the activity
        }
        
        databaseController?.cleanup() // update core data
    }
    
    
    /// User creates the activity
    /// - Parameter sender:
    @IBAction func createActivityButton(_ sender: Any) {
        if let title = titleTextField.text, let notes = notesTextField.text, let dateCompleted = dateCompletedPicker.date as Date?, !title.isEmpty { // get inputs
            let timestamp = Timestamp(date: dateCompleted).seconds // convert date to int
            
            var category: String
            
            switch categorySegmentedControl.selectedSegmentIndex {
            case 0:
                category = "Food"
            case 1:
                category = "Exercise"
            case 2:
                category = "Toilet"
            case 3:
                category = "Groom"
            default:
                category = "Other"
            } // get category string
            
            databaseController?.createNewActivity(title: title, notes: notes, category: category, dateCompleted: Int64(Int(timestamp))) { result in // create new activity in database
                
                if result { // activity created succesfully so pop view
                    self.isSaved = true
                    self.navigationController?.popViewController(animated: true)
                } else { // error so display message
                    self.displayMessage(title: "Error", message: "Error creating activity.")
                }
            }
        } else { // error in input
            displayMessage(title: "Error", message: "Please enter a title.")
        }
        
    }
    
    /// User deletes new activity
    /// - Parameter sender:
    @IBAction func deleteAction(_ sender: Any) {
        isSaved = true
        navigationController?.popViewController(animated: true) // pop view
    }
    
    /// Displays a message to the screen
    /// - Parameters:
    ///   - title:
    ///   - message:
    func displayMessage(title: String, message: String) {
                let alertController = UIAlertController(title: title, message: message,
                                                            preferredStyle: .alert)
                    
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
                                                            handler: nil))
                    
                self.present(alertController, animated: true, completion: nil)
        }
}
