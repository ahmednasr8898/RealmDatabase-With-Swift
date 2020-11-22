//
//  ViewController.swift
//  RealmDatabaseDemo
//
//  Created by Ahmed Nasr on 11/14/20.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var realm = try! Realm()
    var persons: Results<PersonModel>!
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        loadDataInTableView()
    }
    //Insert Data to Realm Database
    @IBAction func addDataOnClick(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New person", message: "", preferredStyle: .alert)
        alert.addTextField { (txt) in txt.placeholder = "name"}
        alert.addTextField { (txt) in txt.placeholder = "age"}
        let addButton = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let name = alert.textFields?[0].text, !name.isEmpty, let age = alert.textFields?[1].text, !age.isEmpty else {return}
            //Add data in database
            let person = PersonModel()
            person.name = name
            person.age = Int(age) ?? 0
            try! self.realm.write {
                self.realm.add(person)
                print("Add New Person")
            }
        }
        alert.addAction(addButton)
        self.present(alert, animated: true, completion: nil)
    }
    //Delete All Data
    @IBAction func deleteAllDataOnClick(_ sender: UIBarButtonItem) {
        try! self.realm.write {
            realm.deleteAll()
        }
    }
    //for go to Upload and retrive image
    @IBAction func goToPhotoPageOnClick(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoViewController")
        navigationController?.pushViewController(storyboard, animated: true)
    }
}
//TableView With DataSource
extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = persons[indexPath.row].name
        cell.detailTextLabel?.text = String(persons[indexPath.row].age)
        return cell
    }
}
//TableView With Delegate
extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //for delete item
        let delete = UIContextualAction(style: .destructive, title: "delete") { (_, _, _) in
            //select item for deleting
            let personSelected = self.persons[indexPath.row]
            //delete selected item
            try! self.realm.write {
                self.realm.delete(personSelected)
                print("item deleted")
            }
        }
        //for edit item
        let edit = UIContextualAction(style: .normal, title: "edit") { (_, _, _) in
            let alert = UIAlertController(title: "Edit person", message: "", preferredStyle: .alert)
            alert.addTextField()
            alert.addTextField()
            //select item for editing
            let personSelected = self.persons[indexPath.row]
            alert.textFields?[0].text = personSelected.name
            alert.textFields?[1].text = String(personSelected.age)
            let addButton = UIAlertAction(title: "edit", style: .default) { (_) in
                guard let name = alert.textFields?[0].text, !name.isEmpty, let age = alert.textFields?[1].text, !age.isEmpty else {return}
                //edit seleced item
                try! self.realm.write({
                    personSelected.name = name
                    personSelected.age = Int(age)!
                    print("Item editing")
                })
            }
            alert.addAction(addButton)
            self.present(alert, animated: true, completion: nil)  
        }
        return UISwipeActionsConfiguration(actions: [delete,edit])
    }
}
//Loading Data In TableView With NotifiactionToken
extension ViewController{
    func loadDataInTableView(){
        self.persons = self.realm.objects(PersonModel.self)
        notificationToken = persons.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                // Always apply updates in the following order: deletions, insertions, then modifications.
                // Handling insertions before deletions may result in unexpected behavior.
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
}

