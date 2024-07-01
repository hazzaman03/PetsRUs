//
//  PetBreedTableViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 2/6/2024.
//

import UIKit

/**
 View Controller for Pet Breed selection
 */
class PetBreedTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var newPetDelegate: NewPetViewController?
    var indicator = UIActivityIndicatorView()
    var searchController: UISearchController?
    
    var petType: String? {
        didSet {
            Task {
                await updateBreeds(petType: petType) // call api when type of pet changes
            }
        }
    }
    var allBreeds: [String] = []
    var filteredBreeds: [String] = []

    /**
     ViewDidLoad for Pet Breed view controller
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search Breeds"
        navigationItem.searchController = searchController
        definesPresentationContext = true // setting up search controller to search for breed
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerYAnchor)
        ])
        indicator.startAnimating() // setup loading indicator to load whilst api is fetching
        
    }

    /**
     Updates the search results when a user searches for a breed
     - Parameter searchController:
     */
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        } // gets text from search bar
        
        if searchText.count > 0 { // if user has searched something
            filteredBreeds = allBreeds.filter({ (breed: String) -> Bool in
                return (breed.lowercased().contains(searchText))
            })
        } else {
            filteredBreeds = allBreeds // havent searched anything so include all results
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
        if filteredBreeds.isEmpty  { // no breeds so display only 1 row
            if indicator.isAnimating {
                return 0 // still fetching so display no rows
            }
            return 1
        }
        
        return filteredBreeds.count
    }

    /**
     Fomart Cell
     - Parameters:
     - tableView:
     - indexPath:
     - Returns:
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "breedCell", for: indexPath)

        if filteredBreeds.isEmpty { // no breeds in filtered response but user can add it as a custom breed
            cell.textLabel?.text = "No breeds found - Add breed anyway?"
        } else {
            cell.textLabel?.text = filteredBreeds[indexPath.row]
        }
        
        return cell
    }
    
    /**
     User selects a breed
     - Parameters:
     - tableView:
     - indexPath:
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filteredBreeds.isEmpty, let searchText = searchController?.searchBar.text { // no results found so add custom breed
            if searchText.isEmpty { // no custom breed provided so show error
                tableView.deselectRow(at: indexPath, animated: true)
                displayMessage(title: "Error", message: "Please enter a breed to continue")
            }
            
            newPetDelegate?.breed = searchText // update breed and pop view
            navigationController?.popViewController(animated: true)
        } else {
            newPetDelegate?.breed = filteredBreeds[indexPath.row] // did select valid breed
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    /**
     Calls API to update the pet breeds
     - Parameters:
     - petType: The type of pet user is creating, ie dog/cat/other
     */
    func updateBreeds(petType: String?) async {
        allBreeds = []
        filteredBreeds = []
        if let type = petType {
            if type == "Other" { // pet type is other so cant fetch breeds
                tableView.reloadData()
                indicator.stopAnimating()
                return
            }
            
            var searchURLComponents = URLComponents()
            searchURLComponents.scheme = "https"
            searchURLComponents.host = "api.the\(type.lowercased())api.com"
            searchURLComponents.path = "/v1/breeds" // loading api address
            
            guard let requestURL = searchURLComponents.url else {
                print("Invalid URL.")
                return
            } // create request
            
            let urlRequest = URLRequest(url: requestURL)
            do {
                let (data, _) = try await URLSession.shared.data(for: urlRequest) // fetch data
                
                indicator.stopAnimating() // stop the loading bar when data is fetched
                
                do {
                    let decoder = JSONDecoder()
                    let breedData = try decoder.decode([BreedInfo].self, from: data) // decode data as list of breeds
                    
                    for breed in breedData {
                        allBreeds.append(breed.name)
                        filteredBreeds.append(breed.name)
                    } // add all breeds to displayed lists
                    
                    tableView.reloadData()
                    
                } catch let error_ {
                    print(error_)
                } // error decoding
            }
            catch let error {
                print(error)
            } // error fetching
            
        }
    }
    
    /**
     Displays a message to the screen.
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
