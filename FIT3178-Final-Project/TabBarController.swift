//
//  TabBarController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 22/4/2024.
//

import UIKit

/// Controller for tab bar
class TabBarController: UITabBarController {
    
    /// ViewDidLoad for tab bar
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.items?[0].title = "Home"
        tabBar.items?[1].title = "Activites"
        tabBar.items?[2].title = "Reminders"
        tabBar.items?[3].title = "Settings" // update the captions
        
        tabBar.items?[0].image = UIImage(systemName: "house")
        tabBar.items?[1].image = UIImage(systemName: "figure.walk")
        tabBar.items?[2].image = UIImage(systemName: "calendar")
        tabBar.items?[3].image = UIImage(systemName: "gearshape") // update the icons
        
    }
}
