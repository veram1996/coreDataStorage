//
//  CategoryViewController.swift
//  CoreDataStorage
//
//  Created by Dheeraj Verma on 18/07/21.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {
    var categoryArray: [NewCategory] =  []
    @IBOutlet weak var tableView: UITableView!
    let request: NSFetchRequest<NewCategory> =  NewCategory.fetchRequest()
    let context =  CoreDataManager.coreDataManager.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems(request: request)
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        let alert =  UIAlertController(title: "Add New Todory Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let item =  NewCategory(context: self.context)
            item.name = textfield.text
            self.categoryArray.append(item)
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

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text =  categoryArray[indexPath.row].name
        return cell
    }
 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      performSegue(withIdentifier: "goToItem", sender: self)
    }
    
    func saveItem() {

        do {
            try context.save()

        } catch {
            print("Error \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    func loadItems(request: NSFetchRequest<NewCategory>) {
        do  {
           categoryArray = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
}
