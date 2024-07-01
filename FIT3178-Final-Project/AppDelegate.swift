//
//  AppDelegate.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 22/4/2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var databaseController: DatabaseProtocol?
    var window: UIWindow?
    
    var notificationsEnabled = false
    static let NOTIFICATION_IDENTIFIER = "edu.monash.fit3178.final-project"
    static let CATEGORY_IDENTIFIER = "edu.monash.fit3178.final-project.category"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        databaseController = FirebaseController()
        
        Task {
            let notificationCenter = UNUserNotificationCenter.current()
            let notificationSettings = await notificationCenter.notificationSettings()
            if notificationSettings.authorizationStatus == .notDetermined {
                let granted = try await notificationCenter.requestAuthorization(options: [.alert])
                self.notificationsEnabled = granted
            }
            else if notificationSettings.authorizationStatus == .authorized {
                self.notificationsEnabled = true
            }
        }
        
        let acceptAction = UNNotificationAction(identifier: "accept", title: "Accept", options: .foreground)
        
        let declineAction = UNNotificationAction(identifier: "decline", title: "Decline", options: .destructive)
        
        // Set up the category
        let appCategory = UNNotificationCategory(identifier: AppDelegate.CATEGORY_IDENTIFIER, actions: [acceptAction, declineAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        
        // Register the category just created with the notification centre
        UNUserNotificationCenter.current().setNotificationCategories([appCategory])
        
        UNUserNotificationCenter.current().delegate = self
        
        
        
        return true
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent
     notification: UNNotification, withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification received")
        completionHandler([.banner])
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

