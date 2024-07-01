//
//  SettingsTableViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 22/4/2024.
//

import UIKit

/**
 View Controller for Settings
 */
class SettingsTableViewController: UITableViewController, DatabaseListener {
    
    var listenerType: ListenerType = .pet
    weak var databaseController: DatabaseProtocol?
    
    var currentPet: PetClass?
    
    @IBOutlet weak var nameTextField: UITextField!
    
    /**
     ViewDidLoad for Settings
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController // setting database
                
    }
    
    /**
     ViewDidAppear for Settings
     - Parameter animated:
     */
    override func viewDidAppear(_ animated: Bool) {
        databaseController?.addListener(listener: self) // add listener
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
        return 5 // 5 total settings options
    }
    
    /**
     Fomat Cell
     - Parameters:
     - tableView:
     - indexPath:
     - Returns:
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 { // Account settings
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
            
            cell.textLabel?.text = "Account Settings"
            
            return cell
        } else if indexPath.row == 1 { // Change pet
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
            
            cell.textLabel?.text = "Select Pet"
            
            return cell
        } else if indexPath.row == 2 { // Invite owner
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
            
            cell.textLabel?.text = "Invite Owner"
            
            return cell
        } else if indexPath.row == 3 { // New Pet
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
            
            cell.textLabel?.text = "New Pet"
            
            return cell
        } else { // acknowledgements
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
            
            cell.textLabel?.text = "Acknowledgments"
            
            return cell
        }
        
    }
    
    /**
     User selects setting option
     - Parameters:
     - tableView:
     - indexPath:
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { // segue to account settings
            performSegue(withIdentifier: "accountSettingsSegue", sender: self)
        }
        
        if indexPath.row == 1 { // segue to select pet
            performSegue(withIdentifier: "selectPetSegue", sender: self)
        }
        
        if indexPath.row == 2 { // segue to invite owner
            performSegue(withIdentifier: "inviteOwnerSegue", sender: self)
        }
        
        if indexPath.row == 3 { // segue to new pet
            performSegue(withIdentifier: "newPetSegue", sender: self)
        }
        
        if indexPath.row == 4 { // segue to acknowledgements
            performSegue(withIdentifier: "acknowledgementsSegue", sender: self)
        }
        
    }
    
    /**
     Prepare for invite owner segue
     - Parameters:
     - segue:
     - sender:
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "inviteOwnerSegue" {
            let destination = segue.destination as! InviteOwnerTableTableViewController
            destination.currentPet = currentPet // set current pet so it can fetch owners of current pet
        }
    }
    
    ///
    /// - Parameters:
    ///   - isSuccessful:
    ///   - error:
    func onAuthChange(isSuccessful: Bool, error: (any Error)?) {
        // do nothing
    }
    
    /**
     Pet has changed pet name label
     */
    func onPetChange(change: DatabaseChange, userPet: PetClass?) {
        currentPet = userPet
        DispatchQueue.main.async { // ensures main thread updates UI
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
    
    ///
    /// - Parameters:
    ///   - change:
    ///   - petReminders:
    func onReminderChange(change: DatabaseChange, petReminders: [ReminderClass]) {
        // do nothing
    }
    
}
