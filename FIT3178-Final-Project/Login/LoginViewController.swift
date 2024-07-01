//
//  LoginViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 1/5/2024.
//

import UIKit

/**
 View Controller for Login View
 */

class LoginViewController: UIViewController, DatabaseListener {
    
    var listenerType: ListenerType = .auth
    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    /**
     ViewDidLoad for Login View
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        databaseController?.addListener(listener: self) // setting database and adding listener
        
        databaseController?.checkUserStatus() ?? false ? segueToApp() : () // if user is logged in then send them straight to app
        
        emailTextField.textContentType = .username
        emailTextField.keyboardType = .emailAddress
        passwordTextField.textContentType = .password // setting for auto fill
        
    }
    
    /**
    Detects when user has been signed in.
     - Parameters:
        - isSuccessful: Whether the sign in was successful or not
        - error: if there was an error with sign in
     */
    func onAuthChange(isSuccessful: Bool, error: (any Error)?) {
        if isSuccessful { // successful sign in
            segueToApp()
        } else {
            displayMessage(title: "Error", message: "Failed to Login")
        }
    }
    
    /**
     When the user presses sign in
     - Parameter sender:
     */
    @IBAction func signInAction(_ sender: Any) {
        
        if let password = passwordTextField.text, let email = emailTextField.text, !email.isEmpty, !password.isEmpty {
            databaseController?.signInToFirebase(email: email, password: password) // get info and login
        } else {
            displayMessage(title: "Error", message: "Please enter an email and password") // user hasnt entered password and email properly
        }
    }
    
    /**
     Segues the user to the app
     */
    func segueToApp() {
        
        databaseController?.setupPets() // setup the users pets
        
        
        let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController")
        
        navigationController.modalPresentationStyle = .fullScreen
        
        self.present(navigationController, animated: true, completion: nil) // setup nav controller and push user to it
    }
    
    /**
     Displays a message to the screen
     */
    func displayMessage(title: String, message: String) {
                let alertController = UIAlertController(title: title, message: message,
                                                            preferredStyle: .alert)
                    
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
                                                            handler: nil))
                    
                self.present(alertController, animated: true, completion: nil)
        }
    
    ///
    /// - Parameters:
    ///   - change:
    ///   - userPet:
    func onPetChange(change: DatabaseChange, userPet: PetClass?) {
        // do nothing
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
