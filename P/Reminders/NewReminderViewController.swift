//
//  NewReminderViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 22/5/2024.
//

import UIKit
import FirebaseFirestore

/// View Controller for New Reminders
class NewReminderViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    weak var databaseController: DatabaseProtocol?
    
    let repeatsOptions = [[String]](repeating: ["None", "Hourly", "Daily", "Weekly", "Fortnightly", "Monthly", "6 Monthly", "Yearly"], count: 800).flatMap{$0}
    
    @IBOutlet weak var repeatPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var titleTextField: UITextField!
    
    var isSaved = false
    
    /// ViewDidLoad for new reminder
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController // setting database
        
        repeatPicker.delegate = self
        repeatPicker.dataSource = self // setting delegate for picker view
        
        
        if let storedReminder = databaseController?.getStoredReminder() { // fetch stored reminder if there is one
            titleTextField.text = storedReminder.title
            datePicker.date = storedReminder.reminderDate ?? Date()
            
            switch storedReminder.repeats {
            case "None":
                repeatPicker.selectRow(400, inComponent: 0, animated: true)
            case "Hourly":
                repeatPicker.selectRow(401, inComponent: 0, animated: true)
            case "Daily":
                repeatPicker.selectRow(402, inComponent: 0, animated: true)
            case "Weekly":
                repeatPicker.selectRow(403, inComponent: 0, animated: true)
            case "Fortnightly":
                repeatPicker.selectRow(404, inComponent: 0, animated: true)
            case "Monthly":
                repeatPicker.selectRow(405, inComponent: 0, animated: true)
            case "6 Monthly":
                repeatPicker.selectRow(406, inComponent: 0, animated: true)
            case "Yearly":
                repeatPicker.selectRow(407, inComponent: 0, animated: true)
            default:
                repeatPicker.selectRow(400, inComponent: 0, animated: true)
            } // update all the fields if there is a stored reminder
        } else {
            repeatPicker.selectRow(400, inComponent: 0, animated: true)
            datePicker.minimumDate = Date() // no stored reminder so set inputs to default
        }
    }
    
    
    /// Update the stored reminder
    /// - Parameter animated:
    override func viewDidDisappear(_ animated: Bool) {
        databaseController?.deleteStoredReminder() // delete current stored reminder
        
        if !isSaved { // reminder needs to be stored so it saves
            var repeatsString: String
            
            switch repeatPicker.selectedRow(inComponent: 0) % 8 {
            case 0:
                repeatsString = "None"
            case 1:
                repeatsString = "Hourly"
            case 2:
                repeatsString = "Daily"
            case 3:
                repeatsString = "Weekly"
            case 4:
                repeatsString = "Fortnightly"
            case 5:
                repeatsString = "Monthly"
            case 6:
                repeatsString = "6 Monthly"
            case 7:
                repeatsString = "Yearly"
            default:
                repeatsString = "None"
            } // getting repeat string, ie hourly/daily etc
            
            databaseController?.storeReminder(title: titleTextField.text ?? "", reminderDate: datePicker.date, repeats: repeatsString) // store this reminder
        }
        
        databaseController?.cleanup() // update coredata
    }
    
    
    /// Create the new reminder
    /// - Parameter sender:
    @IBAction func createAction(_ sender: Any) {
        if let title = titleTextField.text, !title.isEmpty, let dueDate = datePicker.date as Date? { // get inputs
            
            let timestamp = Timestamp(date: dueDate).seconds // converting timestamp to int
            
            let repeats = repeatPicker.selectedRow(inComponent: 0) // get selected repeats
            
            var repeatsString: String
            
            switch repeats % 8 {
            case 0:
                repeatsString = "None"
            case 1:
                repeatsString = "Hourly"
            case 2:
                repeatsString = "Daily"
            case 3:
                repeatsString = "Weekly"
            case 4:
                repeatsString = "Fortnightly"
            case 5:
                repeatsString = "Monthly"
            case 6:
                repeatsString = "6 Monthly"
            case 7:
                repeatsString = "Yearly"
            default:
                repeatsString = "None"
            } // gets the string to store
            
            databaseController?.createNewReminder(title: title, dueDate: timestamp, repeats: repeatsString) { result in
                // try to create new reminder
                if result { // success so pop view
                    self.isSaved = true
                    self.navigationController?.popViewController(animated: true)
                } else { // error so display message
                    self.displayMessage(title: "Error", message: "Error creating reminder.")
                }
                
            }
        } else { // invalid inputs
            displayMessage(title: "Error", message: "Please enter a title.")
        }
    }
    
    ///
    /// - Parameter pickerView:
    /// - Returns:
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    ///
    /// - Parameters:
    ///   - pickerView:
    ///   - component:
    /// - Returns:
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return repeatsOptions.count
    }
    
    ///
    /// - Parameters:
    ///   - pickerView:
    ///   - row:
    ///   - component:
    /// - Returns:
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return repeatsOptions[row]
    }
    
    /// User deletes new reminder
    /// - Parameter sender:
    @IBAction func deleteAction(_ sender: Any) {
        isSaved = true
        navigationController?.popViewController(animated: true)
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
