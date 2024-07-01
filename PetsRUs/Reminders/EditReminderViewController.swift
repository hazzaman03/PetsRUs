//
//  EditReminderViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 22/5/2024.
//

import UIKit
import FirebaseFirestore

/// View Controller for editing reminders
class EditReminderViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var databaseController: DatabaseProtocol?
    
    let repeatsOptions = [[String]](repeating: ["None", "Hourly", "Daily", "Weekly", "Fortnightly", "Monthly", "6 Monthly", "Yearly"], count: 800).flatMap{$0}

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var repeatsPicker: UIPickerView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var reminder: ReminderClass?
    var editiedReminder: ReminderClass?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController // setting database
        
        repeatsPicker.delegate = self
        repeatsPicker.dataSource = self // setting delegate for picker view
        
        titleTextField.text = reminder?.title
        datePicker.date = Date(timeIntervalSince1970: TimeInterval(reminder!.dueDate)) // setting date and title
        
        switch reminder?.repeats {
        case "None":
            repeatsPicker.selectRow(400, inComponent: 0, animated: true)
        case "Hourly":
            repeatsPicker.selectRow(401, inComponent: 0, animated: true)
        case "Daily":
            repeatsPicker.selectRow(402, inComponent: 0, animated: true)
        case "Weekly":
            repeatsPicker.selectRow(403, inComponent: 0, animated: true)
        case "Fortnightly":
            repeatsPicker.selectRow(404, inComponent: 0, animated: true)
        case "Monthly":
            repeatsPicker.selectRow(405, inComponent: 0, animated: true)
        case "6 Monthly":
            repeatsPicker.selectRow(406, inComponent: 0, animated: true)
        case "Yearly":
            repeatsPicker.selectRow(407, inComponent: 0, animated: true)
        default:
            repeatsPicker.selectRow(400, inComponent: 0, animated: true)
        } // set repeats picker
    }
    
    /// User deletes reminder
    /// - Parameter sender:
    @IBAction func deleteAction(_ sender: Any) {
        let alert = UIAlertController(title: "CAUTION", message: "This is a permenant action and cannot be undone.", preferredStyle: .alert) // alert for confirming deletion
        
        let deleteAction = UIAlertAction(title: "Delete Reminder", style: .destructive, handler: { _ in
            self.databaseController?.deleteReminder(reminder: self.reminder!) // delete reminder
            self.navigationController?.popViewController(animated: true)
        }
        ) // delete action
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(dismissAction)
        
        self.present(alert, animated: true, completion: nil) // presenting confirmation to screen
    }
    
    /// User saves reminder
    /// - Parameter sender:
    @IBAction func saveAction(_ sender: Any) {
        if let title = titleTextField.text, !title.isEmpty { // get text
            
            var repeats: String
            switch repeatsPicker.selectedRow(inComponent: 0) % 8 {
            case 0:
                repeats = "None"
            case 1:
                repeats = "Hourly"
            case 2:
                repeats = "Daily"
            case 3:
                repeats = "Weekly"
            case 4:
                repeats = "Fortnightly"
            case 5:
                repeats = "Monthly"
            case 6:
                repeats = "6 Monthly"
            case 7:
                repeats = "Yearly"
            default:
                repeats = "None"
            } // get repeats as string
            
            let timestamp = Timestamp(date: datePicker.date as Date).seconds // get date as seconds
            
            if title == reminder?.title, repeats == reminder?.repeats, timestamp == reminder!.dueDate {
                // reminder hasnt been edited so do nothing
            } else {
                editiedReminder = ReminderClass(title: title, dueDate: timestamp, repeats: repeats, createdBy: reminder!.createdBy) // create new reminder and update it in database
                databaseController?.updateReminder(oldReminder: reminder!, newReminder: editiedReminder!)
            }
            
            navigationController?.popViewController(animated: true) // all done so pop view
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
