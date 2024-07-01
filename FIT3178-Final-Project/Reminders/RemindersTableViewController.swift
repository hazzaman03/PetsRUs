//
//  RemindersTableViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 22/4/2024.
//

import UIKit

/// View Controller for all Reminders
class RemindersTableViewController: UITableViewController, DatabaseListener {
    var listenerType: ListenerType = .pet

    @IBOutlet weak var nameTextField: UITextField!
    weak var databaseController: DatabaseProtocol?
    var reminders: [ReminderClass] = []
    var currentPet: PetClass?
    
    var selectedReminder: ReminderClass?
    
    /// ViewDidLoad for Reminders
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        databaseController?.addListener(listener: self)
        
    }
    
    /// Updates reminders and pet
    /// - Parameter animated:
    override func viewDidAppear(_ animated: Bool) {
        databaseController?.invokeListeners()
    }
    
    ///
    /// - Parameter tableView:
    /// - Returns:
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    ///
    /// - Parameters:
    ///   - tableView:
    ///   - section:
    /// - Returns:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { // only 1 row in the message display section
            return 1
        }
        
        return reminders.count
    }

    
    /// Format Cell
    /// - Parameters:
    ///   - tableView:
    ///   - indexPath:
    /// - Returns:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if reminders.isEmpty, indexPath.section == 1 { // if reminders is empty show empy message
            let cell = tableView.dequeueReusableCell(withIdentifier: "summaryCell", for: indexPath)
            cell.textLabel?.text = "No current reminders. Please add a reminder."
            cell.accessoryType = .none
            
            return cell
            
        } else if indexPath.section == 1 { // reminders is not empty no need to show error
            let cell = tableView.dequeueReusableCell(withIdentifier: "summaryCell", for: indexPath)
            cell.textLabel?.text = ""
            cell.accessoryType = .none
            
            return cell
        }
        

        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        let cellReminder = reminders[indexPath.row] // get the reminder for this cell
        
        
        
        let dueDateString = Date(timeIntervalSince1970: TimeInterval(cellReminder.dueDate))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "en_AU") // formats date for string
        
        content.text = cellReminder.title
        
        content.secondaryText = "Due Date: \(dateFormatter.string(from: dueDateString)) \nRepeats: \(cellReminder.repeats) \nCreated by: \(cellReminder.createdBy)" // setting cell text
        
        
        cell.accessoryType = .disclosureIndicator
        
        cell.contentConfiguration = content
        
        return cell
            
    }
    
    /// User selects row
    /// - Parameters:
    ///   - tableView:
    ///   - indexPath:
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !reminders.isEmpty { // perform segue to edit reminder if there is a reminder
            selectedReminder = reminders[indexPath.row]
            performSegue(withIdentifier: "editReminderSegue", sender: self)
        }
    }
     
    ///
    /// - Parameters:
    ///   - segue:
    ///   - sender:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editReminderSegue" { // update the edit reminder view to display reminder
            let destination = segue.destination as! EditReminderViewController
            destination.reminder = selectedReminder
        }
    }
    
    ///
    /// - Parameters:
    ///   - isSuccessful:
    ///   - error:
    func onAuthChange(isSuccessful: Bool, error: (any Error)?) {
        // do nothing
    }
    
    /// Updates pet label
    /// - Parameters:
    ///   - change:
    ///   - userPet:
    func onPetChange(change: DatabaseChange, userPet: PetClass?) {
        currentPet = userPet
        DispatchQueue.main.async {
            self.nameTextField.text = self.currentPet?.name
        }
    }
    
    ///
    /// - Parameters:
    ///   - change:
    ///   - petActivities:
    func onActivityChange(change: DatabaseChange, petActivities: [ActivityClass]) {
        // do nothing
    }
    
    /// Update reminders
    /// - Parameters:
    ///   - change:
    ///   - petReminders:
    func onReminderChange(change: DatabaseChange, petReminders: [ReminderClass]) {
        reminders = petReminders
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
