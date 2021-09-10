//
//  ViewController.swift
//  Core-Data-Example
//
//  Created by André Arns on 09/09/21.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Data for the table
    var items: [Person?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        context.automaticallyMergesChangesFromParent = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get items from Core Data
        fetchPeople()
    }
    
    func relationshipDemo() {
        // Create family
        let family = Family(context: context)
        family.name = "Arns"
        
        // Create person
        let person = Person(context: context)
        person.name = "André"
        person.age = 22
        person.gender = "Male"
        person.family = family
        
        // Save context
        do {
            try context.save()
        } catch {
            print("Error")
        }
    }
    
    func fetchPeople() {
        // Getch the data from Core Data to display in the tableview
        do {
            let request = Person.fetchRequest() as NSFetchRequest<Person>
            
            // Set filtering and sorting on the request
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            
            self.items = try context.fetch(request)
            
            
            DispatchQueue.main.async { [self] in
                self.tableView.reloadData()
            }
        }
        catch {
            print("Error fetching from Core Data.")
        }
    }
    
    @IBAction func addTaped(_ sender: Any) {
        // Alert
        let alert = UIAlertController(title: "Adicionar pessoa", message: "Qual é o nome da pessoa?", preferredStyle: .alert)
        alert.addTextField()
        
        // Configure button handler
        let submitButton = UIAlertAction(title: "Add", style: .default) { [self] action in
            
            // Textfield for the alert
            let textfield = alert.textFields![0]
            
            // Create person object
            let newPerson = Person(context: self.context)
            newPerson.name = textfield.text
            newPerson.age = 22
            newPerson.gender = "Male"
            
            // Save the data
            do {
                try self.context.save()
            }
            catch {
                print("Error saving data into CoreData")
            }
            
            // Re-fetch the data
            self.fetchPeople()
        }
        
        // Add button
        alert.addAction(submitButton)
        
        // Show Alert
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of people
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath)
        
        // Get person from arrat and set the label
        let person = self.items[indexPath.row]
        
        cell.textLabel?.text = person?.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Selected person
        let person = self.items[indexPath.row]

        // Create alert
        let alert = UIAlertController(title: "Editar pessoa", message: "Editar nome:", preferredStyle: .alert)
        alert.addTextField()

        let textField = alert.textFields![0]
        textField.text = person?.name

        // Configure button handler
        let saveButton = UIAlertAction(title: "Salvar", style: .default) { [self] (action) in
            
            // Get the textfield for the alert
            let textfield = alert.textFields![0]
            
            // Edit name property of person object
            person?.name = textfield.text
            
            // Save the data
            do {
                try self.context.save()
            } catch {
                print("Error editing person")
            }
            
            // Re-fetch the data
            self.fetchPeople()
        }
        
        // Add button
        alert.addAction(saveButton)
        
        // Show alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Create swipe action
        let action = UIContextualAction(style: .destructive, title: "Deletar") { action, view, completionHandler in
            
            // Which person to remove
            let personToRemove = self.items[indexPath.row]
            
            // Remove the person
            self.context.delete(personToRemove!)
            
            // Save the data
            do {
                try self.context.save()
            } catch {
                print("Error deleting person")
            }
            
            // Re-fetch the data
            self.fetchPeople()
        }
        
        // Return swipe actions
        return UISwipeActionsConfiguration(actions: [action])
    }
}

