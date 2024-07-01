//
//  FirebaseController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 23/4/2024.
//

import Foundation

import UIKit
import CoreData
import Firebase
import FirebaseFirestoreSwift

/// Controller for database
class FirebaseController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    var authController: Auth
    var database: Firestore
    
    var currentPet: PetClass?
    var allPets: [PetClass] = []
    var activities: [ActivityClass] = []
    var reminders: [ReminderClass] = []
    
    var currentUserName: String?
    
    /// Initialiser for database
    override init() {
        persistentContainer = NSPersistentContainer(name: "DataModel")
                persistentContainer.loadPersistentStores() { (description, error ) in
                    if let error = error {
                        fatalError("Failed to load Core Data Stack with error: \(error)")
                    }
                } // setup core data

        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore() // setup firestore database
        
        super.init()
    }
    
    
    
    /// Cleans up core data database
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
                    do {
                        try persistentContainer.viewContext.save() // save all changes
                    } catch {
                        fatalError("Failed to save changes to Core Data with error: \(error)")
                    }
                }
    }
    
    /// Invokes all listeners
    func invokeListeners() {
        listeners.invoke { listener in
            
            // loop through all pet listeners and update pet, activities and reminders
            if listener.listenerType == .pet {
                listener.onPetChange(change: .update, userPet: currentPet)
                listener.onActivityChange(change: .update, petActivities: activities)
                listener.onReminderChange(change: .update, petReminders: reminders)
            }
            
        }
    }
    
    
    /// Add listener to multicast delegate
    /// - Parameter listener:
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
    }
    
    /// Remove listener from multicast delegate
    /// - Parameter listener:
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    /// Store activity to core data that hasnt been saved
    /// - Parameters:
    ///   - title:
    ///   - notes:
    ///   - category:
    ///   - dateCompleted:
    func storeActivity(title: String, notes: String, category: String, dateCompleted: Date) {
        let activity = NSEntityDescription.insertNewObject(forEntityName:
                                                        "Activity", into: persistentContainer.viewContext) as! Activity
        activity.default_name = "STORED_ACTIVITY" // always store as this name so it will always be fetched
        activity.title = title
        activity.notes = notes
        activity.category = category
        activity.dateCompleted = dateCompleted // updating other inputs
    }
    
    /// Delete the stored object as the object has been saved to firestore
    func deleteStoredActivity() {
        if let storedActivity = getStoredActivity() { // delete activity
            persistentContainer.viewContext.delete(storedActivity)
        }
    }
    
    /// Gets the stored activity
    /// - Returns:
    func getStoredActivity() -> Activity? {
        var fetchedActivities = [Activity]()
        let request: NSFetchRequest<Activity> = Activity.fetchRequest()
        let predicate = NSPredicate(format: "default_name = %@", "STORED_ACTIVITY") // create fetch request with default name
        request.predicate = predicate
        do {
            try fetchedActivities = persistentContainer.viewContext.fetch(request)
        } catch {
            NSLog("Fetch Request Failed: \(error)")
        }
        if let storedActivity = fetchedActivities.first {
            return storedActivity // if theres an activity there then return it
        }
        
        return nil // return nothing if theres no stored activity
    }
    
    /// Stores unsaved reminder
    /// - Parameters:
    ///   - title:
    ///   - reminderDate:
    ///   - repeats:
    func storeReminder(title: String, reminderDate: Date, repeats: String) {
        let reminder = NSEntityDescription.insertNewObject(forEntityName:
                                                        "Reminder", into: persistentContainer.viewContext) as! Reminder
        reminder.default_name = "STORED_REMINDER" // always set as default name
        reminder.title = title
        reminder.reminderDate = reminderDate
        reminder.repeats = repeats // updating other inputs
    }
    
    /// Deletes the stored reminder
    func deleteStoredReminder() {
        if let storedReminder = getStoredReminder() {
            persistentContainer.viewContext.delete(storedReminder)
        }
    }
    
    /// Get stored reminder
    /// - Returns:
    func getStoredReminder() -> Reminder? {
        var fetchedReminders = [Reminder]()
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        let predicate = NSPredicate(format: "default_name = %@", "STORED_REMINDER") // fetch reminder with default nam
        request.predicate = predicate
        do {
            try fetchedReminders = persistentContainer.viewContext.fetch(request)
        } catch {
            NSLog("Fetch Request Failed: \(error)")
        }
        if let storedReminder = fetchedReminders.first {
            return storedReminder // there is a stored reminder so return it
        }
        return nil // no reminder to return nothing
    }
    
    /// Store unsaved pet
    /// - Parameters:
    ///   - name:
    ///   - type:
    ///   - breed:
    func storePet(name: String, type: String, breed: String) {
        let pet = NSEntityDescription.insertNewObject(forEntityName:
                                                        "Pet", into: persistentContainer.viewContext) as! Pet
        pet.default_name = "STORED_PET" // store as default name
        pet.name = name
        pet.type = type
        pet.breed = breed // update other inputs
    }
    
    /// Delete storesd pet
    func deleteStoredPet() {
        if let storedPet = getStoredPet() {
            persistentContainer.viewContext.delete(storedPet)
        }
    }
    
    /// Get stored pet
    /// - Returns:
    func getStoredPet() -> Pet? {
        var fetchedPets = [Pet]()
        let request: NSFetchRequest<Pet> = Pet.fetchRequest()
        let predicate = NSPredicate(format: "default_name = %@", "STORED_PET") // create request with default name
        request.predicate = predicate
        do {
            try fetchedPets = persistentContainer.viewContext.fetch(request)
        } catch {
            NSLog("Fetch Request Failed: \(error)")
        }
        if let storedPet = fetchedPets.first {
            return storedPet // there is a pet so return it
        }
        return nil // no pet found so return nil
    }
    
    /// Fetches all the pets for the current user. Called whenever user is logged in or they create a new pet
    func setupPets() {
        Task{
            if let userid = authController.currentUser?.uid{ // get user id for reference
                do {
                    let user = try await database.collection("Users").document(userid).getDocument(as: UserClass.self)
                    // getting user and decoding
                    
                    let pets = user.pets
                    var newAllPets: [PetClass] = [] // array where all pets will be stored
                    
                    if !pets.isEmpty { // loop through pets references
                        for pet in pets { // weve got pets so add them to our pets
                            let retrievedPet = try await database.collection("Pets").document(pet).getDocument(as: PetClass.self)
                            newAllPets.append(retrievedPet)
                        }
                        
                        allPets = newAllPets
                        currentPet = allPets[0]
                        activities = currentPet?.activities ?? []
                        reminders = currentPet?.reminders ?? [] // set current pet, activities and reminders from the first pet
                        
                        
                        for pet in allPets {
                            setupPetListener(pet: pet)
                        } // setup listeners for database
                        
                        updateNotifications() // update notifications
                        
                    }
                    
                    // invoke the listeners to update activities, reminders, home page etc.
                    listeners.invoke { listener in
                        
                        if listener.listenerType == .pet {
                            listener.onPetChange(change: .update, userPet: currentPet)
                            listener.onActivityChange(change: .update, petActivities: activities)
                            listener.onReminderChange(change: .update, petReminders: reminders)
                        }
                        
                    }
                    
                } catch {
                    NSLog("Error decoding pet: \(error)")
                }
            }
        }
    }
    
    /// Signs a user into firebase
    /// - Parameters:
    ///   - email:
    ///   - password:
    func signInToFirebase(email: String, password: String) {
        authController.signIn(withEmail: email, password: password) { result, error in // signs in using auth controller
            
            self.listeners.invoke { listener in
                
                if listener.listenerType == .auth {
                    
                    let wasSuccessful = result != nil && error == nil // if it was successful and no error
                    
                    listener.onAuthChange(isSuccessful: wasSuccessful, error: error) // was successful so alert listeners to let the user in
                }
            }
        }
        
    }
    
    /// Signs a user up to firebase
    /// - Parameters:
    ///   - email:
    ///   - password:
    ///   - name:
    func signUpToFirebase(email: String, password: String, name: String) {
        
        authController.createUser(withEmail: email, password: password) { result, error in // signs up
            self.listeners.invoke { listener in
                if listener.listenerType == .auth {
                    let wasSuccessful = result != nil && error == nil // if user successfully signed in
                    
                    if wasSuccessful { // if was successful we also want to create this user in the database
                        self.createFirebaseUser(email: email, name: name)
                        NSLog("User created")
                    }
                    listener.onAuthChange(isSuccessful: wasSuccessful, error: error) // update listeners to segue user in
                }
            }
        }
    }
    
    /// Signs a user out from firebase
    /// - Returns:
    func signOut() -> Bool {
        do {
            try authController.signOut() // did sign out so return true so user will be segued out
            NSLog("Signed out")
            return true
        } catch {
            return false
        }
    }
    
    
    /// Creates a user in the database to store users info
    /// - Parameters:
    ///   - email:
    ///   - name:
    func createFirebaseUser(email: String, name: String){
        
        if let userid = authController.currentUser?.uid { // get users id
            
            let u = UserClass(id: userid, email: email, name: name, pets: []) // create blank user
            
            do {
                try database.collection("Users").document(userid).setData(from: u) // add blank user to db
                NSLog("User added to db")
            } catch let error {
                NSLog("Error writing city to Firestore: \(error)")
            }
            
        }
    }
    
    /// Changes the users name
    /// - Parameters:
    ///   - name:
    ///   - completion:
    func setUsername(name: String, with completion: @escaping(Bool)->()) {
        if let userid = authController.currentUser?.uid { // get user id to access database
            
            database.collection("Users").document(userid).setData(["name": name], merge: true) { error in
                // update name field and return true or false if it was successful or not
                if let _ = error {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    
    /// Gets the current users name
    /// - Parameter completion:
    func getUsername(with completion: @escaping(String)->()) {
        
        if let userid = authController.currentUser?.uid { // get user id to access database
            database.collection("Users").document(userid).getDocument { (document, error) in
                if let document = document, document.exists { // get document and get its data
                    let docData = document.data()
                    let name = docData!["name"] as? String ?? "" // pull out the name from data
                    completion(name) // return name
                } else {
                    completion("")
                }
            }
            
        }
    }
    
    /// Checks user status so user can be auto logged in
    /// - Returns:
    func checkUserStatus() -> Bool {
        if let _ = authController.currentUser?.uid {
            return true // there is a user so send them in automatically
        }
        return false
    }
    
    /// Deletes an account entirely
    /// - Parameter completion:
    func deleteAccount(with completion: @escaping(Bool)->()) {
        
        if let userid = authController.currentUser?.uid { // get id for reference
            
            database.collection("Users").document(userid).delete() // delete the doc
            
            authController.currentUser?.delete { error in // also remove user from auth controller
                if let _ = error {
                    completion(false)
                } else {
                    completion(true) // no error so return true
                }
            }
        }
    }
    
    /// Creates a new pet in the database
    /// - Parameters:
    ///   - name:
    ///   - type:
    ///   - breed:
    ///   - completion:
    func createNewPet(name: String, type: String, breed: String, with completion: @escaping(Bool)->()) {
        if let userid = authController.currentUser?.uid { // get user id for database reference
            
            let p = PetClass(id: "", name: name, breed: breed, type: type, activities: [], reminders: []) // create new blank pet
            
            do {
                let docRef = try database.collection("Pets").addDocument(from: p) { error in // add the pet to all pets
                    if let _ = error {
                        completion(false)
                    }
                }
                
                database.collection("Pets").document(docRef.documentID).setData(["id": docRef.documentID], merge: true) { error in // update the pets id for further reference
                    if let _ = error {
                        completion(false)
                    }
                }
                
                database.collection("Users").document(userid).updateData([ // update users pets so that they will be able to access it
                    "pets" : FieldValue.arrayUnion([docRef.documentID])
                ]) { error in
                    
                    if let _ = error {
                        completion(false)
                    } else {
                        self.allPets.append(p)
                        self.currentPet = p
                        self.activities = p.activities
                        self.reminders = p.reminders
                        completion(true) // update all pets and set the current pet so that they dont have to select it
                    }
                }
                
            } catch let error {
                NSLog("Error writing city to Firestore: \(error)")
                completion(false)
            }
        }
    }
    
    
    /// Gets all the pets
    /// - Returns:
    func getAllPets() -> [PetClass]{
        return allPets
    }
    
    /// sets the current pet to selected pet
    /// - Parameter pet:
    func setPet(pet: PetClass) {
        currentPet = pet
        
        activities = pet.activities
        reminders = pet.reminders // update variables
        
        listeners.invoke { listener in
            
            if listener.listenerType == .pet { // notify all listeners
                listener.onPetChange(change: .update, userPet: currentPet)
                listener.onActivityChange(change: .update, petActivities: activities)
                listener.onReminderChange(change: .update, petReminders: reminders)
            }
            
        }
        
    }
    
    /// Sets up firestore listeners for realtime updates
    /// - Parameter pet:
    func setupPetListener(pet: PetClass) {
        let petRef = database.collection("Pets") // get pet collection
        petRef.whereField("id", isEqualTo: pet.id).addSnapshotListener { // setup listners if ids match
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, let petSnapshot =
                    querySnapshot.documents.first else {
                print("Error fetching teams: \(error!)")
                return
            }
            self.parsePetSnapshot(snapshot: petSnapshot) // parse the snapshot when a change is detected.
        }
        
        
    }
    
    /// Parses through snapshot to update pet data
    /// - Parameter snapshot:
    func parsePetSnapshot(snapshot: QueryDocumentSnapshot) {
        do {
            let petSnapshot = try snapshot.data(as: PetClass.self) // decode data as pet
            
            for var pet in allPets { // loop through all the pets and update the activities and reminders if theyve been changed
                if pet.id == petSnapshot.id {
                    pet.activities = petSnapshot.activities
                    pet.reminders = petSnapshot.reminders
                }
            }
            
            if currentPet?.id == petSnapshot.id { // update current pet if its been changed
                activities = petSnapshot.activities
                reminders = petSnapshot.reminders
            }
            
            updateNotifications() // update notifications
            
            listeners.invoke { listener in // let all listeners know of changes
                
                if listener.listenerType == .pet {
                    listener.onPetChange(change: .update, userPet: currentPet)
                    listener.onActivityChange(change: .update, petActivities: activities)
                    listener.onReminderChange(change: .update, petReminders: reminders)
                    
                }
                
            }
        } catch {
            NSLog("Error decoding pet")
        }
    }
    
    /// Creates a new activity in the databse
    /// - Parameters:
    ///   - title:
    ///   - notes:
    ///   - category:
    ///   - dateCompleted:
    ///   - completion:
    func createNewActivity(title: String, notes: String, category: String, dateCompleted: Int64, with completion: @escaping(Bool)->()) {
        
        if let pet = currentPet { // get current pet as this will be changed
            
            getUsername() { userName in // gets username to update who completed the activity
                let a = ActivityClass(title: title, notes: notes, category: category, dateCompleted: dateCompleted, createdBy: userName) // create new activity
                do {
                    let encoded = try Firestore.Encoder().encode(a) // encode activitiy
                    
                    self.database.collection("Pets").document(pet.id).updateData([
                        "activities" : FieldValue.arrayUnion([encoded]) // add activity
                    ]) { error in
                        if let _ = error { // if theres an error uploading
                            completion(false)
                        }
                        completion(true)
                    }
                } catch {
                    NSLog("Error creating activity")
                }
            }
        }
    }
    
    /// Updates activity in the database
    /// - Parameters:
    ///   - oldActivity:
    ///   - newActivity:
    func updateActivity(oldActivity: ActivityClass, newActivity: ActivityClass) {
        if let pet = currentPet { // get current pet for database
            Task {
                do {
                    let doc = try await database.collection("Pets").document(pet.id).getDocument() // get current pet
                    
                    if let fetchedActivities = doc.get("activities") as? [[String: Any]] { // get the activities
                        if let toDelete = fetchedActivities.first(where: { (element) -> Bool in // tells us which activity has been changed so we can delete it
                            
                            // the predicate for finding the element
                            if let title = element["title"] as? String, let notes = element["notes"] as? String, let category = element["category"] as? String, let dateCompleted = element["dateCompleted"] as? Int, title == oldActivity.title, notes == oldActivity.notes, category == oldActivity.category, dateCompleted == oldActivity.dateCompleted { // if all elements line up this is the one we delete
                                return true
                            } else {
                                return false
                            }
                        }) {
                            // element found, remove it
                            try await database.collection("Pets").document(pet.id).updateData([
                                "activities": FieldValue.arrayRemove([toDelete])
                            ])
                        }
                    }
                    
                    let encodedNew = try Firestore.Encoder().encode(newActivity) // now want to add new activity
                    
                    try await database.collection("Pets").document(pet.id).updateData([ // add it to activities
                        "activities" : FieldValue.arrayUnion([encodedNew])])
                    
                } catch {
                    NSLog("Error saving activity")
                }
            }
        }
    }
    
    /// Deletes an activity
    /// - Parameter activity:
    func deleteActivity(activity: ActivityClass) {
        if let pet = currentPet {
            Task {
                do {
                    let doc = try await database.collection("Pets").document(pet.id).getDocument() // gets the pet document
                    
                    if let fetchedActivities = doc.get("activities") as? [[String: Any]] { // get the data
                        if let toDelete = fetchedActivities.first(where: { (element) -> Bool in // finds the corresponding activity that needs to be deleted
                            
                            // the predicate for finding the element
                            if let title = element["title"] as? String, let notes = element["notes"] as? String, let category = element["category"] as? String, let dateCompleted = element["dateCompleted"] as? Int, title == activity.title, notes == activity.notes, category == activity.category, dateCompleted == activity.dateCompleted {
                                return true
                            } else {
                                return false
                            }
                        }) {
                            // element found, remove it
                            try await database.collection("Pets").document(pet.id).updateData([
                                "activities": FieldValue.arrayRemove([toDelete])
                            ])
                        }
                    }
                } catch {
                    NSLog("Error deleting activity")
                }
            }
        }
    }
    
    
    /// Creates a new reminder in the database
    /// - Parameters:
    ///   - title:
    ///   - dueDate:
    ///   - repeats:
    ///   - completion:
    func createNewReminder(title: String, dueDate: Int64, repeats: String, with completion: @escaping (Bool) -> ()) {
        if let pet = currentPet { // gets current pet as the reminder will be added to this
            
            getUsername() { userName in // gets username to add it to reminder object
                let r = ReminderClass(title: title, dueDate: dueDate, repeats: repeats, createdBy: userName) // creates reminder object
                do {
                    let encoded = try Firestore.Encoder().encode(r) // encode object
                    
                    self.database.collection("Pets").document(pet.id).updateData([
                        "reminders" : FieldValue.arrayUnion([encoded]) // add this object to database
                    ]) { error in
                        if let _ = error {
                            completion(false)
                        }
                        completion(true) // no error so can return true
                    }
                } catch {
                    NSLog("Error creating reminder")
                }
            }
            
        }
    }
    
    /// Updates a reminder in the database
    /// - Parameters:
    ///   - oldReminder:
    ///   - newReminder:
    func updateReminder(oldReminder: ReminderClass, newReminder: ReminderClass) {
        if let pet = currentPet { // gets current pet to update
            Task {
                do {
                    let doc = try await database.collection("Pets").document(pet.id).getDocument() // gets the document that needs to be updates
                    
                    if let fetchedActivities = doc.get("reminders") as? [[String: Any]] { // gets data
                        if let toDelete = fetchedActivities.first(where: { (element) -> Bool in // finds reminder that needs to be deleted
                            
                            // the predicate for finding the element
                            if let title = element["title"] as? String, let repeats = element["repeats"] as? String, let dueDate = element["dueDate"] as? Int, title == oldReminder.title, repeats == oldReminder.repeats, dueDate == oldReminder.dueDate {
                                return true
                            } else {
                                return false
                            }
                        }) {
                            // element found, remove it
                            try await database.collection("Pets").document(pet.id).updateData([
                                "reminders": FieldValue.arrayRemove([toDelete])
                            ])
                        }
                    }
                    
                    
                    let encodedNew = try Firestore.Encoder().encode(newReminder) // encode new reminder
                    
                    try await database.collection("Pets").document(pet.id).updateData([
                        "reminders" : FieldValue.arrayUnion([encodedNew])]) // upload reminder to database
                    
                } catch {
                    NSLog("Error saving reminder")
                }
            }
        }
    }
    
    /// Deletes reminder from database
    /// - Parameter reminder:
    func deleteReminder(reminder: ReminderClass) {
        if let pet = currentPet { // gets current pet to know what to delete from
            Task {
                do {
                    
                    let doc = try await database.collection("Pets").document(pet.id).getDocument() // getting current reminders
                    if let fetchedActivities = doc.get("reminders") as? [[String: Any]] { // get data
                        if let toDelete = fetchedActivities.first(where: { (element) -> Bool in // find which object to delete
                            
                            // the predicate for finding the element
                            if let title = element["title"] as? String, let repeats = element["repeats"] as? String, let dueDate = element["dueDate"] as? Int, title == reminder.title, repeats == reminder.repeats, dueDate == reminder.dueDate {
                                return true
                            } else {
                                return false
                            }
                        }) {
                            // element found, remove it
                            try await database.collection("Pets").document(pet.id).updateData([
                                "reminders": FieldValue.arrayRemove([toDelete])
                            ])
                        }
                    }
                }
            }
        }
    }
    
    /// Updates the notifications in the notification centre
    /// - Parameter pet:
    func updateNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
        { (granted, error) in
            if !granted {
                NSLog("Permission was not granted!")
                return
            } // get permissions from user
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // removes all the notifications so it can update them
            for pet in self.allPets {
                // loops through all reminders to add each one
                for reminder in pet.reminders {
                    let content = UNMutableNotificationContent()
                    content.title = "Reminder - \(pet.name)"
                    content.body = reminder.title
                    
                    var request: UNNotificationRequest? // creating a request which will be added
                    
                    if reminder.repeats == "None" { // reminder doesnt repeat so can just let it send after time
                        
                        let elapsed = Date(timeIntervalSince1970: TimeInterval(reminder.dueDate)).timeIntervalSince(Date())
                        // finding how long till the reminder will trigger
                        
                        NSLog("\(elapsed)")
                        
                        if elapsed > 0 { // if it still needs to go off
                            
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: elapsed, repeats: false)
                            
                            request = UNNotificationRequest(identifier: "\(pet.id) - \(pet.name) - \(reminder.title) - \(UUID().uuidString)", content: content, trigger: trigger) // create request and trigger
                        }
                        
                    } else if reminder.repeats == "Hourly" {
                        let date = Date(timeIntervalSince1970: TimeInterval(reminder.dueDate))
                        let calendar = Calendar.current
                        
                        let minute = calendar.component(.minute, from: date)
                        
                        var dateComponents = DateComponents()
                        dateComponents.minute = minute
                        
                        // sets date components. fires every hour so only needs to check if the minute is the same.
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        
                        request = UNNotificationRequest(identifier: "\(pet.id) - \(pet.name) - \(reminder.title) - \(UUID().uuidString)", content: content, trigger: trigger)
                        
                    } else if reminder.repeats == "Daily" {
                        let date = Date(timeIntervalSince1970: TimeInterval(reminder.dueDate))
                        let calendar = Calendar.current
                        
                        let hour = calendar.component(.hour, from: date)
                        let minute = calendar.component(.minute, from: date)
                        
                        var dateComponents = DateComponents()
                        dateComponents.hour = hour
                        dateComponents.minute = minute
                        
                        // sets date components. fires every day so checks minute and hour
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        
                        request = UNNotificationRequest(identifier: "\(pet.id) - \(pet.name) - \(reminder.title) - \(UUID().uuidString)", content: content, trigger: trigger)
                    } else if reminder.repeats == "Weekly" {
                        let date = Date(timeIntervalSince1970: TimeInterval(reminder.dueDate))
                        let calendar = Calendar.current
                        
                        let day = calendar.component(.weekday, from: date)
                        let hour = calendar.component(.hour, from: date)
                        let minute = calendar.component(.minute, from: date)
                        
                        var dateComponents = DateComponents()
                        dateComponents.day = day
                        dateComponents.hour = hour
                        dateComponents.minute = minute
                        
                        // sets date components. fires every week so checks minute, hour and day
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        
                        request = UNNotificationRequest(identifier: "\(pet.id) - \(pet.name) - \(reminder.title) - \(UUID().uuidString)", content: content, trigger: trigger)
                    } else if reminder.repeats == "Fortnightly" {
                        let date = Date(timeIntervalSince1970: TimeInterval(reminder.dueDate))
                        let calendar = Calendar.current
                        
                        let day = calendar.component(.weekday, from: date)
                        let hour = calendar.component(.hour, from: date)
                        let minute = calendar.component(.minute, from: date)
                        
                        var dateComponents = DateComponents()
                        dateComponents.weekday = day
                        dateComponents.day = day
                        dateComponents.hour = hour
                        dateComponents.minute = minute
                        
                        // sets date components. fires every fortnight so checks minute, hour, day and week number
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        
                        request = UNNotificationRequest(identifier: "\(pet.id) - \(pet.name) - \(reminder.title) - \(UUID().uuidString)", content: content, trigger: trigger)
                    } else if reminder.repeats == "Monthly" {
                        let date = Date(timeIntervalSince1970: TimeInterval(reminder.dueDate))
                        let calendar = Calendar.current
                        
                        let week = calendar.component(.weekOfMonth, from: date)
                        let day = calendar.component(.weekday, from: date)
                        let hour = calendar.component(.hour, from: date)
                        let minute = calendar.component(.minute, from: date)
                        
                        var dateComponents = DateComponents()
                        dateComponents.weekOfMonth = week
                        dateComponents.weekday = day
                        dateComponents.day = day
                        dateComponents.hour = hour
                        dateComponents.minute = minute
                        
                        // sets date components. fires every week so checks minute, hour, day, and week in month
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        
                        request = UNNotificationRequest(identifier: "\(pet.id) - \(pet.name) - \(reminder.title) - \(UUID().uuidString)", content: content, trigger: trigger)
                    } else if reminder.repeats == "6 Monthly" {
                        let date = Date(timeIntervalSince1970: TimeInterval(reminder.dueDate))
                        let calendar = Calendar.current
                        
                        let week = calendar.component(.weekOfMonth, from: date)
                        let day = calendar.component(.weekday, from: date)
                        let hour = calendar.component(.hour, from: date)
                        let minute = calendar.component(.minute, from: date)
                        
                        var dateComponents = DateComponents()
                        dateComponents.weekOfMonth = week
                        dateComponents.weekday = day
                        dateComponents.day = day
                        dateComponents.hour = hour
                        dateComponents.minute = minute
                        
                        // sets date components. fires every week so checks minute, hour, day, week in month and month in year
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        
                        request = UNNotificationRequest(identifier: "\(pet.id) - \(pet.name) - \(reminder.title) - \(UUID().uuidString)", content: content, trigger: trigger)
                    } else if reminder.repeats == "Yearly" {
                        let date = Date(timeIntervalSince1970: TimeInterval(reminder.dueDate))
                        let calendar = Calendar.current
                        
                        let month = calendar.component(.weekOfYear, from: date)
                        let day = calendar.component(.weekday, from: date)
                        let hour = calendar.component(.hour, from: date)
                        let minute = calendar.component(.minute, from: date)
                        
                        var dateComponents = DateComponents()
                        dateComponents.weekOfYear = month
                        dateComponents.weekday = day
                        dateComponents.day = day
                        dateComponents.hour = hour
                        dateComponents.minute = minute
                        
                        // sets date components. fires every week so checks minute, hour, day, week, and month
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        
                        request = UNNotificationRequest(identifier: "\(pet.id) - \(pet.name) - \(reminder.title) - \(UUID().uuidString)", content: content, trigger: trigger)
                    }
                    
                    
                    if let r = request {
                        UNUserNotificationCenter.current().add(r) // got the request to add it to notification centre
                    }
                    
                }
            }
        }
    }
    
    /// Gets all users in database
    /// - Parameter completion:
    func getAllUsers(with completion: @escaping ([UserClass]) -> ()) {
        var allUsers: [UserClass] = []
        
        database.collection("Users").getDocuments { (querySnapshot, error) in // gets documents
            if let error = error {
                NSLog("Error getting documents: \(error.localizedDescription)")
                completion(allUsers)
                
            } else {
                for document in querySnapshot!.documents { // loops through each document
                    
                    let decoded = UserClass.init(id: document["id"] as! String, email: document["email"] as! String, name: document["name"] as! String, pets: document["pets"] as! [String]) // creates user object from data
                    allUsers.append(decoded) // add it to list
                    
                    
                }
                completion(allUsers) // return all users
            }
        }
    }
    
    /// Adds a pet to a user
    /// - Parameters:
    ///   - user:
    ///   - completion:
    func addPetToUser(user: UserClass, with completion: @escaping (Bool) -> ()) {
        if let pet = currentPet { // gets current pet
            database.collection("Users").document(user.id).updateData([
                "pets" : FieldValue.arrayUnion([pet.id]) // adds it to users pet array
            ]) { error in
                
                if let _ = error {
                    completion(false)
                } else {
                    completion(true) // no errors so return true
                }
            }
        } else {
            completion(false)
        }
    }
    
}
