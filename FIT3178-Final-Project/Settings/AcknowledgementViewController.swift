//
//  AcknowledgementViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 5/6/2024.
//

import UIKit

/// View Controller for Acknowledgement Info
class AcknowledgementViewController: UIViewController {

    @IBOutlet weak var cotentsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var acknowledgement: Dictionary<String, String>?
    
    /// ViewDidLoad for View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cotentsLabel.text = acknowledgement?["contents"]
        titleLabel.text = acknowledgement?["name"] // update the title and info for acknowledgement
        
        cotentsLabel.numberOfLines = 0
        titleLabel.numberOfLines = 0
        
        title = "Info" // update view title
    }
}
