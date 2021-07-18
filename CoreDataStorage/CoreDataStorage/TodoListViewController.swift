//
//  ViewController.swift
//  CoreDataStorage
//
//  Created by Dheeraj Verma on 18/07/21.
//

import UIKit
import CoreData

class TodoListViewController: UIViewController {
    var itemArray: [Item] =  []
    
    @IBOutlet weak var tableView: UITableView!
    let request: NSFetchRequest<Item> =  Item.fetchRequest()
    var selectedCategory: NewCategory?
    
    let context =  CoreDataManager.coreDataManager.persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    
        loadItems(request: request)
    }
    
}

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> =  Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        loadItems(request: request)
       
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems(request: request)
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text =  itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
       // itemArray[indexPath.row].done = !(itemArray[indexPath.row].done)
       
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        self.saveItem()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func saveItem() {

        do {
            try context.save()

        } catch {
            print("Error \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    func loadItems(request: NSFetchRequest<Item>, perdicates: NSPredicate? = nil) {
        let localPredicates =  NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
       
        if let additionalPredicates = perdicates {
            let companountPredicates =  NSCompoundPredicate(andPredicateWithSubpredicates: [localPredicates,additionalPredicates])
            request.predicate = companountPredicates
        } else {
            request.predicate = localPredicates
        }
        do  {
           itemArray = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        tableView.reloadData()

    }
}

extension TodoListViewController {
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        let alert =  UIAlertController(title: "Add New Todory Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let item =  Item(context: self.context)
            item.title = textfield.text
            item.done = false
            item.parentCategory =  self.selectedCategory
            self.itemArray.append(item)
            self.saveItem()
           // self.tableView.reloadData()
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Create new item"
            textfield = textField
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}
