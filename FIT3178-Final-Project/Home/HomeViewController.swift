//
//  HomeViewController.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 3/6/2024.
//

import UIKit
import SwiftUI

/// View Controller for Home View
class HomeViewController: UIViewController, DatabaseListener, UITableViewDataSource, UITableViewDelegate {
    
    var listenerType: ListenerType = .pet
    weak var databaseController: DatabaseProtocol?
    
    let animalOptions = ["dog", "cat", "bird"]
    
    var currentPet: PetClass?
    var reminders: [ReminderClass] = []
    var todaysReminders: [ReminderClass] = []
    var activities: [ActivityClass] = []
    var selectedReminder: ReminderClass?

    var indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var todaysRemindersTable: UITableView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var factLabel: UILabel!
    
    /// ViewDidLoad for Home view
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        databaseController?.addListener(listener: self) // setting database and adding listener
        
        todaysRemindersTable.delegate = self
        todaysRemindersTable.dataSource = self
        todaysRemindersTable.separatorStyle = .none // setting reminder table delegate and data source
        
        factLabel.text = "" // setting fact to none whilst loading
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:
                                                factLabel.topAnchor)
        ])
        indicator.startAnimating() // start loading indicator
        
    }
    
    ///
    /// - Parameter animated:
    override func viewDidAppear(_ animated: Bool) {
        databaseController?.invokeListeners()
    }
    
    ///
    /// - Parameters:
    ///   - tableView:
    ///   - section:
    /// - Returns:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if todaysReminders.isEmpty { // no reminders so just show message
            return 1
        }
        
        return todaysReminders.count
    }
    
    ///  Format cell
    /// - Parameters:
    ///   - tableView:
    ///   - indexPath:
    /// - Returns:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        if todaysReminders.isEmpty { // no reminders so display message
            content.text = "No reminders for today."
            cell.accessoryType = .none
            
        } else { // there is a reminder so format reminder
            
            let cellReminder = todaysReminders[indexPath.row]
            
            let dueDateString = Date(timeIntervalSince1970: TimeInterval(cellReminder.dueDate))
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale(identifier: "en_AU") // format string
            
            content.text = cellReminder.title
            
            content.secondaryText = "Due Date: \(dateFormatter.string(from: dueDateString)) \nRepeats: \(cellReminder.repeats) \nCreated by: \(cellReminder.createdBy)" // formatting text
            
            cell.accessoryType = .disclosureIndicator
        }

        cell.contentConfiguration = content
        
        return cell
    }
    
    ///
    /// - Parameters:
    ///   - tableView:
    ///   - indexPath:
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        todaysRemindersTable.deselectRow(at: indexPath, animated: true) // deselect the row before moving on to ensure selection isnt bugged
        if !todaysReminders.isEmpty { // if theres no reminders dont segue anything
            selectedReminder = todaysReminders[indexPath.row]
            performSegue(withIdentifier: "editReminderSegue", sender: self)
        }
    }
    
    ///
    /// - Parameters:
    ///   - segue:
    ///   - sender:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editReminderSegue" { // set edit reminder info
            let destination = segue.destination as! EditReminderViewController
            destination.reminder = selectedReminder
        }
    }
    
    /// Updates the fact on the screen based on pet type
    /// - Parameter petType:
    func updateFact(petType: String?) async {
        if var type = petType {
            if type == "Other" {
                type = animalOptions.randomElement() ?? "dog"
            } // if the type of the pet is other then display a random fact
            
            var searchURLComponents = URLComponents()
            searchURLComponents.scheme = "https"
            searchURLComponents.host = "some-random-api.ml"
            searchURLComponents.path = "/animal/\(type.lowercased())" // url for api
            
            guard let requestURL = searchURLComponents.url else {
                print("Invalid URL.")
                return
            }
            
            let urlRequest = URLRequest(url: requestURL)
            do {
                let (data, _) = try await URLSession.shared.data(for: urlRequest) // get data
                indicator.stopAnimating() // stop animating as we have fetched data
                
                do {
                    let decoder = JSONDecoder()
                    let fact = try decoder.decode(AnimalFact.self, from: data) // decode fact
                    
                    let boldText = "Random Fact - "
                    let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
                    let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs) // formatting string so label is bold but fact is normal

                    let normalText = fact.fact
                    let normalString = NSMutableAttributedString(string:normalText)

                    attributedString.append(normalString)
                    
                    factLabel.attributedText = attributedString
                    factLabel.numberOfLines = 0 // setting label text
                    
                } catch let error_ { // error decoding
                    print(error_)
                }
            }
            catch let error { // error fetching fact
                print(error)
            }
            
        }
    }
    
    
    ///
    /// - Parameters:
    ///   - isSuccessful:
    ///   - error:
    func onAuthChange(isSuccessful: Bool, error: (any Error)?) {
        // do nothing
    }
    
    /// Pet has changed
    /// - Parameters:
    ///   - change:
    ///   - userPet:
    func onPetChange(change: DatabaseChange, userPet: PetClass?) {
        currentPet = userPet // change pet
        
        Task {
            await updateFact(petType: currentPet?.type) // update fact to new pet type
        }
        
        DispatchQueue.main.async {
            self.nameTextField.text = self.currentPet?.name // update name label
        }
    }
    
    ///
    /// - Parameters:
    ///   - change:
    ///   - petActivities:
    func onActivityChange(change: DatabaseChange, petActivities: [ActivityClass]) {
        activities = petActivities // update the activities
        DispatchQueue.main.async { // need to update the chart now
                        
            var activitiesDataArray: [ActivityDataStructure] = [] // stores every category and the count of the category
            
            if !self.activities.isEmpty {
                
                // get all the different categories
                activitiesDataArray.append(ActivityDataStructure(name: "Food", value: self.activities.filter({ item in
                    return item.category == "Food"
                }).count))
                
                activitiesDataArray.append(ActivityDataStructure(name: "Exercise", value: self.activities.filter({ item in
                    return item.category == "Exercise"
                }).count))
                
                activitiesDataArray.append(ActivityDataStructure(name: "Toilet", value: self.activities.filter({ item in
                    return item.category == "Toilet"
                }).count))
                
                activitiesDataArray.append(ActivityDataStructure(name: "Groom", value: self.activities.filter({ item in
                    return item.category == "Groom"
                }).count))
                
                activitiesDataArray.append(ActivityDataStructure(name: "Other", value: self.activities.filter({ item in
                    return item.category == "Other"
                }).count))
                
                let chart = ChartUIView(data: activitiesDataArray)
                let controller = UIHostingController(rootView: chart)
                
                guard let chartView = controller.view else {
                    return
                }
                
                self.view.addSubview(chartView)
                self.addChild(controller)
                chartView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    chartView.topAnchor.constraint(equalTo: self.summaryLabel.bottomAnchor, constant: 20),
                    chartView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30),
                    chartView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30),
                    chartView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 4)
                ]) // create the chart view and put it on the screen
                
            } else { // theres no activities so dont display a chart
                let view = ContentView()
                let controller = UIHostingController(rootView: view)
                
                guard let viewView = controller.view else {
                    return
                }
                self.view.addSubview(viewView)
                self.addChild(controller)
                viewView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    viewView.topAnchor.constraint(equalTo: self.summaryLabel.bottomAnchor, constant: 30),
                    viewView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30),
                    viewView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30),
                    viewView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 4)
                ]) // add blank view to screen
            }
        }
    }
    
    ///
    /// - Parameters:
    ///   - change:
    ///   - petReminders:
    func onReminderChange(change: DatabaseChange, petReminders: [ReminderClass]) {
        reminders = petReminders
        todaysReminders = reminders.filter({reminder in // gets the reminders that need to be shown
            if reminder.repeats == "None" {
                let elapsed = Date(timeIntervalSince1970: TimeInterval(reminder.dueDate)).timeIntervalSince(Date())
                return -(60 * 60 * 24) < elapsed && elapsed < (60 * 60 * 24) // no repeat so checks if its 24 hours away
            } else if reminder.repeats == "Hourly" {
                return true // hourly will always be today
            } else if reminder.repeats == "Daily" {
                return true // daily will always be today
            } else if reminder.repeats == "Weekly" {
                let date = Date(timeIntervalSince1970: TimeInterval(reminder.dueDate))
                let calendar = Calendar.current
                
                let weekDayCurrent = calendar.component(.weekday, from: Date())
                let weekDayDate = calendar.component(.weekday, from: date)
                
                return weekDayDate == weekDayCurrent // weekly only if days match up
            } else if reminder.repeats == "Fortnightly" {
                let date = Date(timeIntervalSince1970: TimeInterval(reminder.dueDate))
                let calendar = Calendar.current
                
                let weekDayCurrent = calendar.component(.weekday, from: Date())
                let weekDayDate = calendar.component(.weekday, from: date)
                
                return weekDayDate == weekDayCurrent // fornightly if days and week of month match
            } else if reminder.repeats == "Monthly" {
                let date = Date(timeIntervalSince1970: TimeInterval(reminder.dueDate))
                let calendar = Calendar.current
                
                let weekDayCurrent = calendar.component(.weekday, from: Date())
                let weekDayDate = calendar.component(.weekday, from: date)
                
                let weekMonthCurrent = calendar.component(.weekOfMonth, from: Date())
                let weekMonthDate = calendar.component(.weekOfMonth, from: date)
                
                return weekDayDate == weekDayCurrent && weekMonthCurrent == weekMonthDate // monthly if days and month match
            } else if reminder.repeats == "6 Monthly" {
                let date = Date(timeIntervalSince1970: TimeInterval(reminder.dueDate))
                let calendar = Calendar.current
                
                let weekDayCurrent = calendar.component(.weekday, from: Date())
                let weekDayDate = calendar.component(.weekday, from: date)
                
                let weekMonthCurrent = calendar.component(.weekOfMonth, from: Date())
                let weekMonthDate = calendar.component(.weekOfMonth, from: date)
                
                return weekDayDate == weekDayCurrent && weekMonthCurrent == weekMonthDate // 6 monthly if days and month match
            }else if reminder.repeats == "Yearly" {
                let date = Date(timeIntervalSince1970: TimeInterval(reminder.dueDate))
                let calendar = Calendar.current
                
                let weekDayCurrent = calendar.component(.weekday, from: Date())
                let weekDayDate = calendar.component(.weekday, from: date)
                
                let weekMonthCurrent = calendar.component(.weekOfMonth, from: Date())
                let weekMonthDate = calendar.component(.weekOfMonth, from: date)
                
                let monthCurrent = calendar.component(.month, from: Date())
                let monthDate = calendar.component(.month, from: date)
                
                return weekDayDate == weekDayCurrent && weekMonthCurrent == weekMonthDate && monthCurrent == monthDate
                // yearly if days, week, month all match
            }
            return true
        })
        
        DispatchQueue.main.async {
            self.todaysRemindersTable.allowsSelection = !self.todaysReminders.isEmpty
            self.todaysRemindersTable.reloadData() // update table to include filtered reminders
        }
    }
}
