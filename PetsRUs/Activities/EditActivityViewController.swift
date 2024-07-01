//
//  EditActivityViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 15/5/2024.
//

import UIKit
import FirebaseFirestore

/// View Controller for editing an activity
class EditActivityViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var dateCompletedPicker: UIDatePicker!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    
    var activity: ActivityClass?
    var edititedActivity: ActivityClass?
    
    /// ViewDidLoad for edit activity
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController // setting database
                
        titleTextField.text = activity?.title
        notesTextField.text = activity?.notes // setting inputs
        
        switch activity?.category {
        case "Food":
            categorySegmentedControl.selectedSegmentIndex = 0
        case "Exercise":
            categorySegmentedControl.selectedSegmentIndex = 1
        case "Toilet":
            categorySegmentedControl.selectedSegmentIndex = 2
        case "Groom":
            categorySegmentedControl.selectedSegmentIndex = 3
        default:
            categorySegmentedControl.selectedSegmentIndex = 4
        } // setting category inputs
        
        dateCompletedPicker.date = Date(timeIntervalSince1970: TimeInterval(activity!.dateCompleted)) // updated date in date picker
        
    }
    
    /// User saves activity
    /// - Parameter sender:
    @IBAction func saveActivity(_ sender: Any) {
        if let title = titleTextField.text, let notes = notesTextField.text, !title.isEmpty { // getting inputs
            
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
                category = "Custom"
            } // getting category string
            
            let timestamp = Timestamp(date: dateCompletedPicker.date as Date).seconds // convert date picker to int
            
            if title == activity?.title, notes == activity?.notes, category == activity?.category, timestamp == activity!.dateCompleted {
                // nothing has changed so dont do anything
            } else { // something has changed so update activity in database
                edititedActivity = ActivityClass(title: title, notes: notes, category: category, dateCompleted: timestamp, createdBy: activity?.createdBy ?? "")
                databaseController?.updateActivity(oldActivity: activity!, newActivity: edititedActivity!)
            }
            
            navigationController?.popViewController(animated: true) // pop view controller
        } else {
            displayMessage(title: "Error", message: "Please enter a title.") // invalid input
        }
    }
    
    /// User deletes activity
    /// - Parameter sender:
    @IBAction func deleteActivity(_ sender: Any) {
        let alert = UIAlertController(title: "CAUTION", message: "This is a permenant action and cannot be undone.", preferredStyle: .alert) // adding confirmation menu
        
        let deleteAction = UIAlertAction(title: "Delete Activity", style: .destructive, handler: { _ in
            self.databaseController?.deleteActivity(activity: self.activity!) // delete activity if user selects this
            self.navigationController?.popViewController(animated: true)
        }
        )
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(dismissAction)
        
        self.present(alert, animated: true, completion: nil) // presenting confirmation
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
