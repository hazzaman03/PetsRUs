//
//  InviteOwnerTableTableViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 3/6/2024.
//

import UIKit

/**
 View Controller for Invite owner view
 */
class InviteOwnerTableTableViewController: UITableViewController, UISearchResultsUpdating {
    
    weak var databaseController: DatabaseProtocol?
    
    var indicator = UIActivityIndicatorView()
    var searchController: UISearchController?
    
    var allUsers: [UserClass] = []
    var filteredUsers: [UserClass] = []
    var currentPet: PetClass?

    /**
     ViewDidLoad for Invite Owner view controller
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController // setting up database
        
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search Users"
        navigationItem.searchController = searchController
        definesPresentationContext = true // setting up search controller for all users
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerYAnchor)
        ])
        indicator.startAnimating() // loading indicator for fetching users
        
        databaseController?.getAllUsers { users in
            self.allUsers = users
            self.filteredUsers = users
            self.tableView.reloadData()
            self.indicator.stopAnimating()
        } // gets all the users an update the table
    }
    
    /**
     Updates the results when a user searches for other users
     - Parameter searchController:
     */
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        } // get text
        
        if searchText.count > 0 { // if there is a search then search users
            filteredUsers = allUsers.filter({ (user: UserClass) -> Bool in
                return (user.name.lowercased().contains(searchText)) || (user.email.lowercased().contains(searchText))
            })
        } else {
            filteredUsers = allUsers // no search so show all users
        }
        tableView.reloadData()
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
        if filteredUsers.isEmpty { // no users found so just so message
            return 1
        }
        
        return filteredUsers.count
    }

    /**
     Format cell
     - Parameters:
     - tableView:
     - indexPath:
     - Returns:
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        if filteredUsers.isEmpty { // no users found so display this message
            content.text = "No users found."
        } else { // users are found so format cell
            content.text = filteredUsers[indexPath.row].name
            content.secondaryText = filteredUsers[indexPath.row].email
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    /**
     User selects a row
     - Parameters:
     - tableView:
     - indexPath:
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filteredUsers.isEmpty {
            tableView.deselectRow(at: indexPath, animated: true)
        } // no users in table so do nothing when selects
        
        if filteredUsers[indexPath.row].pets.contains(currentPet?.id ?? "") { // user already has pet so dont add
            displayMessage(title: "Error", message: "User already owns current pet.")
        } else {
            databaseController?.addPetToUser(user: filteredUsers[indexPath.row]) { result in // add pet to user
                if result { // result successful so pop view
                    self.navigationController?.popViewController(animated: true)
                    self.displayMessage(title: "Success", message: "Successfully added \(self.filteredUsers[indexPath.row].name) as owner")
                } else { // error in adding so make them redo
                    self.displayMessage(title: "Error", message: "Error adding \(self.filteredUsers[indexPath.row].name) as owner")
                }
            }
        }
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
