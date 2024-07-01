//
//  DatabaseProtocol.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 1/5/2024.
//

import Foundation
import FirebaseFirestore

/// Type of database change
enum DatabaseChange {
    case add
    case remove
    case update
}

/// Type of listener
enum ListenerType {
    case pet
    case auth
    case all
}

/// Protocol for defining methods needed by listeners
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onAuthChange(isSuccessful: Bool, error: Error?)
    func onPetChange(change: DatabaseChange, userPet: PetClass?)
    func onActivityChange(change: DatabaseChange, petActivities: [ActivityClass])
    func onReminderChange(change: DatabaseChange, petReminders: [ReminderClass])
    
}

/// Protocol for defining database methods
protocol DatabaseProtocol: AnyObject {
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func invokeListeners()
    
    func signInToFirebase(email: String, password: String)
    func signUpToFirebase(email: String, password: String, name: String)
    func getUsername(with completion: @escaping(String)->())
    func setUsername(name: String, with completion: @escaping(Bool)->())
    func checkUserStatus() -> Bool
    func signOut() -> Bool
    func deleteAccount(with completion: @escaping(Bool)->())
    
    func setupPets()
    func setPet(pet: PetClass)
    func createNewPet(name: String, type: String, breed: String, with completion: @escaping(Bool)->())
    func getAllPets() -> [PetClass]
    func setupPetListener(pet: PetClass)
    
    func createNewActivity(title: String, notes: String, category: String, dateCompleted: Int64, with completion: @escaping(Bool)->())
    func updateActivity(oldActivity: ActivityClass, newActivity: ActivityClass)
    func deleteActivity(activity: ActivityClass)
    
    func createNewReminder(title: String, dueDate: Int64, repeats: String, with completion: @escaping(Bool)->())
    func updateReminder(oldReminder: ReminderClass, newReminder: ReminderClass)
    func deleteReminder(reminder: ReminderClass)
    
    func getAllUsers(with completion: @escaping([UserClass])->())
    func addPetToUser(user: UserClass, with completion: @escaping(Bool)->())
    
    func storeActivity(title: String, notes: String, category: String, dateCompleted: Date)
    func deleteStoredActivity()
    func getStoredActivity() -> Activity?
    
    func storeReminder(title: String, reminderDate: Date, repeats: String)
    func deleteStoredReminder()
    func getStoredReminder() -> Reminder?
    
    func storePet(name: String, type: String, breed: String)
    func deleteStoredPet()
    func getStoredPet() -> Pet?
}
