//
//  AccountSettingsViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 5/5/2024.
//

import UIKit

/**
 View Controller for Account Settings
 */

class AccountSettingsViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    /**
     ViewDidLoad for Account Settings
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController // set database
        
        databaseController?.getUsername { text in
            self.nameTextField.text = text
        } // get the current users name for editing
        
        signOutButton.tintColor = UIColor.red
        deleteAccountButton.tintColor = UIColor.red // setting button colours to red
    }
    
    /**
     When user presses save details
     - Parameter sender:
     */
    @IBAction func saveDetailsAction(_ sender: Any) {
        
        if let name = nameTextField.text, !name.isEmpty { // check if theyve entered a name
            databaseController?.setUsername(name: name) { complete in // set the users new name
                if complete {
                    self.navigationController?.popViewController(animated: true) // if name change was successful segue
                } else {
                    self.displayMessage(title: "Error", message: "Could not update name") // error updating name
                }
            }
        } else {
            displayMessage(title: "Error", message: "Please enter a name") // name field empty
        }
        
    }
    
    /**
     User presses delete account
     - Parameter sender:
     */
    @IBAction func deleteAction(_ sender: Any) {
        let alert = UIAlertController(title: "CAUTION", message: "This is a permenant action and cannot be undone", preferredStyle: .alert) // add message box to confirm deletion
        
        let deleteAction = UIAlertAction(title: "Delete Account", style: .destructive, handler: { _ in
            self.databaseController?.deleteAccount { result in
                if result == true {
                    self.segueToSignin() // user has deleted account so log them out
                }
            }
        } // add action for deleting account and delete accont
        )
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil) // add dismiss action
        
        alert.addAction(deleteAction)
        alert.addAction(dismissAction)
        
        self.present(alert, animated: true, completion: nil) // present alert
    }
    
    /**
     When user presses sign out
     - Parameter sender:
     */
    @IBAction func signoutAction(_ sender: Any) {
        if databaseController?.signOut() == true {
            segueToSignin() // signout and send back to login
        }
    }
    
    /**
     Sends the user back to sign in page
     */
    func segueToSignin() {
        
        let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signInNavigationController")
        
        navigationController.modalPresentationStyle = .fullScreen
        
        self.present(navigationController, animated: true, completion: nil) // create new nav controller and push
        
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
