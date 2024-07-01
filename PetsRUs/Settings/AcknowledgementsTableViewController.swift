//
//  AcknowledgementsTableViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 5/6/2024.
//

import UIKit

/**
 View Controller for Acknowledgements View
 */
class AcknowledgementsTableViewController: UITableViewController {
    var acknowledgements = [
        ["name" : "Multicast Delegate - Michael Wybrow",
         "contents" : "MulticastDelegate.swift\nCreated by Michael Wybrow on 23/3/19.\nCopyright © 2019 Monash University.\n\nLicensed under the Apache License, Version 2.0 (the License);\nyou may not use this file except in compliance with the License.\nYou may obtain a copy of the License at\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software\ndistributed under the License is distributed on an AS IS BASIS,\nWITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\nSee the License for the specific language governing permissions and\nlimitations under the License."
        ],
        ["name" : "Firebase IOS SDK",
         "contents" : "The contents of this repository are licensed under the Apache License, version 2.0. The repository can be found at https://github.com/firebase/firebase-ios-sdk."
        ],
        ["name" : "The Dog API",
         "contents" : "The Dog API provides information and images of dogs. There are a number of endpoints to retrieve different things. The documentation can be found at https://developers.thecatapi.com/. The API website can be found at https://thedogapi.com/."
        ],
        ["name" : "The Cat API",
         "contents" : "The Cat API provides information and images of cats. There are a number of endpoints to retrieve different things. The documentation can be found at https://developers.thecatapi.com/. The API website can be found at https://thecatapi.com/."
        ],
        ["name" : "Some Random API",
         "contents" : "Some Random API has a number of endpoints that provides random facts for a range of topics. These topics include dogs and cats. The documentation can be found at https://some-random-api.ml/docs/welcome/introduction/. The API website can be found at https://some-random-api.ml/."
        ],
        
    ]
    
    var selectedAcknowledgement: Dictionary<String, String>?
    
    /**
     ViewDidLoad for Acknowledgements view
     */
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return acknowledgements.count
    }

    /**
     Format cell
     - Parameters:
     - tableView:
     - indexPath:
     - Returns:
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "acknowledgementCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.text = acknowledgements[indexPath.row]["name"] // get the name of the acknowledgement and update text
        
        cell.contentConfiguration = content
        return cell
    }
    
    /**
     User selects acknowledgements
     - Parameters:
     - tableView:
     - indexPath:
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAcknowledgement = acknowledgements[indexPath.row]
        performSegue(withIdentifier: "acknowledgementInfoSegue", sender: self) // update selection and segue
    }
    
    /**
     Prepare for acknowledgement segue
     - Parameters:
     - segue:
     - sender:  
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! AcknowledgementViewController
        
        if let selected = selectedAcknowledgement {
            destination.acknowledgement = selected
        } // update destination so that it will display information
    }
}
