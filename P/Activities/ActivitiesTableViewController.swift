//
//  ActivitiesTableViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 22/4/2024.
//

import UIKit

/// View Controller for Activities View
class ActivitiesTableViewController: UITableViewController, DatabaseListener {
    
    var listenerType: ListenerType = .pet
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var nameTextField: UITextField!
    
    var activities: [ActivityClass] = []
    var currentPet: PetClass?
    var selectedActivity: ActivityClass?
    
    /// ViewDidLoad for Activities View
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController // setting database
        
        databaseController?.addListener(listener: self) // add self as listener
    }
    
    ///
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
    
    /// User wants to create new activity
    /// - Parameter sender:
    @IBAction func newActivityAction(_ sender: Any) {
        performSegue(withIdentifier: "newActivitySegue", sender: self)
    }
    
    ///
    /// - Parameters:
    ///   - tableView:
    ///   - section:
    /// - Returns:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        
        return activities.count
    }

    
    /// Format Cell
    /// - Parameters:
    ///   - tableView:
    ///   - indexPath:
    /// - Returns:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if activities.isEmpty, indexPath.section == 1 { // no activities so display this message
            let cell = tableView.dequeueReusableCell(withIdentifier: "summaryCell", for: indexPath)
            cell.textLabel?.text = "No current activities. Please add an acitvity."
            cell.accessoryType = .none
            
            return cell
            
        } else if indexPath.section == 1 { // there is reminders so no need to display empty message
            let cell = tableView.dequeueReusableCell(withIdentifier: "summaryCell", for: indexPath)
            cell.textLabel?.text = ""
            cell.accessoryType = .none
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        let cellActivity = activities[indexPath.row] // get cells activity
        
        
        
        let dateCompletedString = Date(timeIntervalSince1970: TimeInterval(cellActivity.dateCompleted))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "en_AU") // format date string
        
        content.text = cellActivity.title
        
        content.secondaryText = "Date Completed: \(dateFormatter.string(from: dateCompletedString)) \nCreated by: \(cellActivity.createdBy)" // updating text
        
        switch cellActivity.category {
        case "Food":
            content.image = UIImage(systemName: "fork.knife.circle")
        case "Exercise":
            content.image = UIImage(systemName: "figure.run")
        case "Toilet":
            content.image = UIImage(systemName: "toilet")
        case "Groom":
            content.image = UIImage(systemName: "scissors")
        default:
            content.image = UIImage(systemName: "square.and.pencil")
        } // update icon based on what type of activity it is
        
        cell.accessoryType = .disclosureIndicator
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    /// User selects activity
    /// - Parameters:
    ///   - tableView:
    ///   - indexPath:
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !activities.isEmpty { // selects activity so segue to edit
            selectedActivity = activities[indexPath.row]
            performSegue(withIdentifier: "editActivitySegue", sender: self)
        }
    }
    
    ///
    /// - Parameters:
    ///   - segue:
    ///   - sender:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editActivitySegue" { // set activity thats going to be edited
            let destination = segue.destination as! EditActivityViewController
            destination.activity = selectedActivity
        }
    }
    
    
    ///
    /// - Parameters:
    ///   - isSuccessful:
    ///   - error:
    func onAuthChange(isSuccessful: Bool, error: (any Error)?) {
        // do nothing
    }
    
    ///
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
        activities = petActivities
        activities = activities.sorted(by: {$0.dateCompleted > $1.dateCompleted})
        
        if activities.isEmpty {
            activities = []
        }
        
        DispatchQueue.main.async {            
            self.tableView.reloadData()
        }
    }
    
    ///
    /// - Parameters:
    ///   - change:
    ///   - petReminders:  
    func onReminderChange(change: DatabaseChange, petReminders: [ReminderClass]) {
        // do nothing
    }

}
